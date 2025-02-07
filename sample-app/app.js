const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        timestamp: new Date()
    });
});

app.get('/', (req, res) => {
    res.json({
        message: 'Hello from EKS!',
        version: '1.0.0'
    });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
