# server.py

from flask import Flask, request, jsonify
import PyPDF2
import re
import random
import torch
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans
from transformers import pipeline
import os
import spacy
import nltk

nltk.download("stopwords")

app = Flask(__name__)

# ✅ Extract Text from PDF
def extract_text_from_pdf(pdf_path):
    text = ""
    try:
        with open(pdf_path, "rb") as file:
            reader = PyPDF2.PdfReader(file)
            for page in reader.pages:
                text += page.extract_text() or ""
    except Exception as e:
        print(f"Error reading PDF: {e}")
    return text

# ✅ Preprocess Text
def preprocess_text(text):
    text = re.sub(r"\n", " ", text)
    text = re.sub(r"[^\w\s\.,!?]", "", text)
    sentences = re.split(r"(?<=[.!?])\s+", text)
    return [sentence.strip() for sentence in sentences if len(sentence) > 10]

# ✅ Generate Questions with ML Model
def generate_questions_ml(text, num_questions=10):
    generator = pipeline("text2text-generation", model="valhalla/t5-small-qg-hl")

    sentences = preprocess_text(text)

    if len(sentences) < num_questions:
        num_questions = len(sentences)

    selected_sentences = random.sample(sentences, num_questions)

    questions = []
    for sentence in selected_sentences:
        try:
            input_text = f"generate question: {sentence}"
            output = generator(input_text, max_length=100, num_return_sequences=1)[0]['generated_text']

            questions.append({
                "question": output,
            })
        except Exception as e:
            print(f"Error generating question for: {sentence} -> {e}")

    return questions

# ✅ Classify Questions into Easy, Medium, Hard
def classify_difficulty(questions):
    texts = [q['question'] for q in questions]

    vectorizer = TfidfVectorizer()
    X = vectorizer.fit_transform(texts)

    kmeans = KMeans(n_clusters=3, random_state=42)
    kmeans.fit(X)

    difficulties = ['Easy', 'Medium', 'Hard']

    for i, q in enumerate(questions):
        q['difficulty'] = difficulties[kmeans.labels_[i]]

    return questions

# ✅ Select Questions by Difficulty
def select_questions_by_difficulty(questions, difficulty, num_questions):
    selected = [q for q in questions if q['difficulty'].lower() == difficulty.lower()]

    if len(selected) < num_questions:
        fallback = [q for q in questions if q['difficulty'].lower() != difficulty.lower()]
        selected += random.sample(fallback, min(num_questions - len(selected), len(fallback)))

    return random.sample(selected, min(num_questions, len(selected)))

# ✅ MCQ Generation
def generate_mcqs(text, num_mcqs=30):
    nlp = spacy.load("en_core_web_md")
    doc = nlp(text)

    sentences = [sent.text.strip() for sent in doc.sents if len(sent.text) > 40]
    keywords = list(set([token.text for token in doc if token.is_alpha and not token.is_stop and len(token.text) > 3]))

    mcqs = []

    while len(mcqs) < num_mcqs:
        sentence = random.choice(sentences)
        if len(keywords) < 4:
            continue

        keyword = random.choice(keywords)
        if keyword not in sentence:
            continue

        question = sentence.replace(keyword, "_____")
        correct_answer = keyword

        distractors = random.sample(keywords, 3)
        while correct_answer in distractors:
            distractors = random.sample(keywords, 3)

        options = [correct_answer] + distractors
        random.shuffle(options)

        mcqs.append({
            "question": question,
            "options": {
                "A": options[0],
                "B": options[1],
                "C": options[2],
                "D": options[3]
            },
            "correct": correct_answer
        })

    return mcqs

# ✅ Classify MCQs into Difficulty Levels
def classify_mcqs(mcqs, num_clusters=3):
    if len(mcqs) < num_clusters:
        num_clusters = len(mcqs)

    vectorizer = TfidfVectorizer(stop_words='english')
    X = vectorizer.fit_transform([mcq['question'] for mcq in mcqs])

    kmeans = KMeans(n_clusters=num_clusters, random_state=42)
    kmeans.fit(X)

    labels = kmeans.labels_
    difficulty_map = {0: 'Easy', 1: 'Medium', 2: 'Hard'}

    for i, mcq in enumerate(mcqs):
        mcq['difficulty'] = difficulty_map[labels[i % num_clusters]]

    return mcqs

# ✅ Select MCQs by Difficulty
def select_mcqs(classified_mcqs, difficulty, num_questions):
    filtered = [mcq for mcq in classified_mcqs if mcq['difficulty'] == difficulty]

    # Fallback if not enough MCQs in the requested difficulty
    if len(filtered) < num_questions:
        fallback = random.sample(classified_mcqs, min(num_questions, len(classified_mcqs)))
        filtered = fallback

    return filtered

# ✅ API Route for Question Generation
@app.route('/generate-questions', methods=['POST'])
def generate_questions():
    user = request.form.get('user')
    password = request.form.get('pass')
    difficulty = request.form.get('difficulty')
    num_questions = int(request.form.get('numQuestions'))

    if 'pdf' not in request.files:
        return jsonify({"error": "No PDF uploaded"}), 400

    pdf_file = request.files['pdf']
    pdf_path = os.path.join("uploads", pdf_file.filename)
    os.makedirs("uploads", exist_ok=True)
    pdf_file.save(pdf_path)

    text = extract_text_from_pdf(pdf_path)
    if not text:
        return jsonify({"error": "No valid text found in the PDF"}), 400

    total_questions = num_questions + 5  # Extra for fallback
    questions = generate_questions_ml(text, total_questions)

    if not questions:
        return jsonify({"error": "No questions generated"}), 500

    classified_questions = classify_difficulty(questions)
    selected_questions = select_questions_by_difficulty(classified_questions, difficulty, num_questions)

    os.remove(pdf_path)

    return jsonify({"questions": selected_questions})

# ✅ New Router: API Route for MCQ Generation
@app.route('/generate-mcqs', methods=['POST'])
def generate_mcqs_api():
    difficulty = request.form.get('difficulty')
    num_mcqs = int(request.form.get('numMCQs'))

    if 'pdf' not in request.files:
        return jsonify({"error": "No PDF uploaded"}), 400

    pdf_file = request.files['pdf']
    pdf_path = os.path.join("uploads", pdf_file.filename)
    os.makedirs("uploads", exist_ok=True)
    pdf_file.save(pdf_path)

    text = extract_text_from_pdf(pdf_path)
    if not text:
        return jsonify({"error": "No valid text found in the PDF"}), 400

    mcqs = generate_mcqs(text, num_mcqs)

    if not mcqs:
        return jsonify({"error": "No MCQs generated"}), 500

    classified_mcqs = classify_mcqs(mcqs)
    selected_mcqs = select_mcqs(classified_mcqs, difficulty, num_mcqs)

    os.remove(pdf_path)

    # ✅ Return MCQs with Answer Key
    return jsonify({
        "mcqs": selected_mcqs,
        "answer_key": [{"question": mcq['question'], "correct": mcq['correct']} for mcq in selected_mcqs]
    })

# ✅ Run Flask Server
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
