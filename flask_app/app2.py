from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os
import random
import spacy
import PyPDF2
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = "uploads"
OUTPUT_FOLDER = "output"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# ✅ Extract Text from PDF
def extract_text_from_pdf(pdf_path):
    text = ""
    with open(pdf_path, "rb") as file:
        reader = PyPDF2.PdfReader(file)
        for page in reader.pages:
            text += page.extract_text() or ""
    return text

# ✅ MCQ Generation Function
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

# ✅ PDF Upload and MCQ Generation Route
@app.route('/upload', methods=['POST'])
def upload_pdf():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    pdf_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(pdf_path)

    text = extract_text_from_pdf(pdf_path)
    mcqs = generate_mcqs(text)

    return jsonify({'mcqs': mcqs})

# ✅ Serve Generated MCQs
@app.route('/output/<filename>')
def get_output(filename):
    return send_from_directory(OUTPUT_FOLDER, filename)

# ✅ Run the Server
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)



# from flask import Flask, request, jsonify, send_from_directory
# from flask_cors import CORS
# import os
# import random
# import spacy
# import PyPDF2
# from sklearn.feature_extraction.text import TfidfVectorizer
# from sklearn.cluster import KMeans

# app = Flask(__name__)
# CORS(app)

# UPLOAD_FOLDER = "uploads"
# OUTPUT_FOLDER = "output"
# os.makedirs(UPLOAD_FOLDER, exist_ok=True)
# os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# # ✅ Home Route
# @app.route('/')
# def home():
#     return jsonify({'message': 'Server is running 🚀'}), 200

# # ✅ Extract Text from PDF
# def extract_text_from_pdf(pdf_path):
#     text = ""
#     with open(pdf_path, "rb") as file:
#         reader = PyPDF2.PdfReader(file)
#         for page in reader.pages:
#             text += page.extract_text() or ""
#     return text

# # ✅ MCQ Generation Function
# def generate_mcqs(text, num_mcqs=30):
#     nlp = spacy.load("en_core_web_md")
#     doc = nlp(text)

#     sentences = [sent.text.strip() for sent in doc.sents if len(sent.text) > 40]
#     keywords = list(set([token.text for token in doc if token.is_alpha and not token.is_stop and len(token.text) > 3]))

#     mcqs = []

#     while len(mcqs) < num_mcqs:
#         sentence = random.choice(sentences)
#         if len(keywords) < 4:
#             continue

#         keyword = random.choice(keywords)
#         if keyword not in sentence:
#             continue

#         question = sentence.replace(keyword, "_____")
#         correct_answer = keyword

#         distractors = random.sample(keywords, 3)
#         while correct_answer in distractors:
#             distractors = random.sample(keywords, 3)

#         options = [correct_answer] + distractors
#         random.shuffle(options)

#         mcqs.append({
#             "question": question,
#             "options": {
#                 "A": options[0],
#                 "B": options[1],
#                 "C": options[2],
#                 "D": options[3]
#             },
#             "correct": correct_answer
#         })

#     return mcqs

# # ✅ PDF Upload and MCQ Generation Route
# @app.route('/upload', methods=['POST'])
# def upload_pdf():
#     if 'file' not in request.files:
#         return jsonify({'error': 'No file part'}), 400

#     file = request.files['file']
#     if file.filename == '':
#         return jsonify({'error': 'No selected file'}), 400

#     pdf_path = os.path.join(UPLOAD_FOLDER, file.filename)
#     file.save(pdf_path)

#     text = extract_text_from_pdf(pdf_path)
#     mcqs = generate_mcqs(text)

#     return jsonify({'mcqs': mcqs})

# # ✅ Serve Generated MCQs
# @app.route('/output/<filename>')
# def get_output(filename):
#     return send_from_directory(OUTPUT_FOLDER, filename)

# # ✅ Generate MCQs from Raw Text (New Route)
# @app.route('/generate-mcqs', methods=['POST'])
# def generate_from_text():
#     data = request.get_json()
    
#     if not data or 'text' not in data:
#         return jsonify({'error': 'No text provided'}), 400

#     text = data['text']
#     num_mcqs = data.get('num_mcqs', 30)

#     mcqs = generate_mcqs(text, num_mcqs)
    
#     return jsonify({'mcqs': mcqs})

# # ✅ Run the Server
# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000)
