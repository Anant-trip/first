<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error Page</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .error-container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            text-align: center;
            max-width: 500px;
        }
        .error-code {
            font-size: 48px;
            color: #667eea;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .error-message {
            font-size: 20px;
            color: #333;
            margin-bottom: 20px;
        }
        .error-details {
            font-size: 14px;
            color: #666;
            margin-bottom: 30px;
            text-align: left;
            background: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
        }
        a {
            display: inline-block;
            padding: 12px 30px;
            background: #667eea;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
            margin: 5px;
        }
        a:hover {
            background: #764ba2;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">⚠️ Error</div>
        <div class="error-message">Something went wrong!</div>
        
        <div class="error-details">
            <p><strong>Status:</strong> ${requestScope['jakarta.servlet.error.status_code']}</p>
            <p><strong>Message:</strong> ${requestScope['jakarta.servlet.error.message']}</p>
            <p><strong>Path:</strong> ${requestScope['jakarta.servlet.error.request_uri']}</p>
        </div>
        
        <div>
            <a href="/login">Go to Login</a>
            <a href="/">Go to Home</a>
        </div>
    </div>
</body>
</html>
