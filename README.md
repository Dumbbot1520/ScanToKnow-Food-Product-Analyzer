# Scan-to-Know

Scan-to-Know is a smart food analysis application that helps users understand packaged food products and make healthier choices. Many consumers struggle to read ingredient labels, identify harmful additives, and understand the health impact of processed foods. This project solves that problem using barcode scanning, OCR-based ingredient extraction, and intelligent food analysis.

The application allows users to scan packaged products using either barcode scanning or OCR (Optical Character Recognition). Barcode scanning fetches product information instantly, while OCR extracts ingredients directly from product labels. The extracted data is then analyzed using a structured MongoDB database containing ingredients, additives, categories, and product variants.

The system identifies harmful additives, preservatives, and risky ingredients, then provides simple explanations, health insights, and risk classifications. It also calculates important food quality indicators such as CPHS (Custom Product Health Score), NOVA Group, and Nutri-Score to help users quickly understand how healthy a product is.

In addition to analysis, Scan-to-Know also recommends healthier alternatives, encouraging users to make better food decisions instead of simply avoiding products.

## Features

- Barcode-based product scanning
- OCR-based ingredient extraction
- Ingredient and additive analysis
- Harmful additive detection
- CPHS (Consumer Product Health Score)
- NOVA Group classification
- Nutri-Score evaluation
- Healthier alternative recommendations
- Structured MongoDB food database
- User-friendly Flutter mobile application

## Tech Stack

### Frontend
- Flutter

### Backend
- Node.js
- Express.js

### Database
- MongoDB

### OCR & Scanning
- OCR.Space API
- Google ML Kit
- Mobile Scanner

## Project Goal

The main goal of Scan-to-Know is to simplify complex food labels and convert them into easy-to-understand health insights. The project promotes awareness, preventive healthcare, and smarter everyday food choices through technology-driven food analysis.

## Future Scope

- Personalized health recommendations
- Disease-based food warnings
- Regional language support
- AI-powered food insights
- User dietary preference filters

## Contributors

- Project developed as part of an academic and health-focused food analysis initiative.
