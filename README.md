# Scan-to-Know

Scan-to-Know is a smart food analysis application that helps users understand packaged food products and make healthier choices. Many consumers struggle to read ingredient labels, identify harmful additives, and understand the health impact of processed foods. This project solves that problem using barcode scanning, OCR-based ingredient extraction, and intelligent food analysis.

The application allows users to scan packaged products using either barcode scanning or OCR (Optical Character Recognition). Barcode scanning fetches product information instantly, while OCR extracts ingredients directly from product labels. The extracted data is then analyzed using a structured MongoDB database containing ingredients, additives, categories, and product variants.

The system identifies harmful additives, preservatives, and risky ingredients, then provides simple explanations, health insights, and risk classifications. It also calculates important food quality indicators such as CPHS (Custom Product Health Score), NOVA Group, and Nutri-Score to help users quickly understand how healthy a product is.

In addition to analysis, Scan-to-Know also recommends healthier alternatives, encouraging users to make better food decisions instead of simply avoiding products.

## Before using the project ensure you add your MONGODB URI and OCR SPACE API KEY in the .env file in the backend folder and then run the backend.

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


## Outputs 

<img width="1037" height="582" alt="image" src="https://github.com/user-attachments/assets/5dad56b6-ac5a-4498-8986-e9362e8eff2e" />

<img width="1034" height="580" alt="image" src="https://github.com/user-attachments/assets/8c5a1f45-70b1-4c5f-b90e-73cb116d536d" />

<img width="1038" height="585" alt="image" src="https://github.com/user-attachments/assets/02914393-bc09-470d-a675-59ff129633c7" />

<img width="1034" height="578" alt="image" src="https://github.com/user-attachments/assets/054509c5-53cb-4728-b07e-67d0378be4e8" />

## Contributors
- OM MUJUMDAR 
- PARTH MISHRA (github - https://github.com/nparth29)
- PRATHAMESH RANE (github - https://github.com/ORION-pax07)
