# 📌 Import Libraries
from flask import Flask, request, jsonify
from flask_cors import CORS
import pdfplumber
import nltk
from nltk.tokenize import sent_tokenize
import os

# ✅ Download NLTK data
nltk.download('punkt')

# 📌 Initialize Flask App
app = Flask(__name__)
CORS(app)

# 📌 PDF Extraction Function
def extract_text_from_pdf(pdf_file):
    """Extract text from PDF."""
    text = ""
    with pdfplumber.open(pdf_file) as pdf:
        for page in pdf.pages:
            text += page.extract_text() or ''
    return text

# 📌 Question Generator Function
def generate_questions(text, num_questions, difficulty):
    """Generate questions sequentially based on user input."""
    sentences = sent_tokenize(text)

    # ✅ Filter sentences by difficulty
    if difficulty == "easy":
        filtered_sentences = [s for s in sentences if len(s.split()) <= 12]
    elif difficulty == "average":
        filtered_sentences = [s for s in sentences if 12 < len(s.split()) <= 20]
    else:
        filtered_sentences = [s for s in sentences if len(s.split()) > 20]

    # ✅ Adjust question count
    num_questions = min(num_questions, len(filtered_sentences))

    # ✅ Generate questions sequentially
    questions = [f"Q{i+1}. {filtered_sentences[i]}" for i in range(num_questions)]

    return questions

# 📌 API Route for PDF Upload and Question Generation
@app.route('/generate-questions', methods=['POST'])
def generate():
    if 'pdf' not in request.files:
        return jsonify({'error': 'No PDF file uploaded'}), 400

    pdf_file = request.files['pdf']
    difficulty = request.form.get('difficulty', 'easy').lower()
    num_questions = int(request.form.get('num_questions', 5))

    if pdf_file and pdf_file.filename.endswith('.pdf'):
        pdf_path = os.path.join('uploads', pdf_file.filename)
        
        # ✅ Save uploaded PDF temporarily
        os.makedirs('uploads', exist_ok=True)
        pdf_file.save(pdf_path)

        # ✅ Extract PDF content
        text = extract_text_from_pdf(pdf_path)

        # ✅ Generate questions
        questions = generate_questions(text, num_questions, difficulty)

        # ✅ Clean up the uploaded file
        os.remove(pdf_path)

        # ✅ Return questions as JSON
        return jsonify({
            'difficulty': difficulty,
            'num_questions': num_questions,
            'questions': questions
        })
    
    return jsonify({'error': 'Invalid PDF file'}), 400

# 📌 Run the Server
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
