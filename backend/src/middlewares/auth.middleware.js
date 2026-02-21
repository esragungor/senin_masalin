import { admin } from '../config/firebase.js';

/**
 * Firebase Auth Token doğrulama middleware'i
 * Flutter'dan gelen `Authorization: Bearer <token>` header'ını doğrular
 */
export const authenticate = async (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({
            error: 'Yetkisiz erişim. Lütfen giriş yapın.',
            code: 'UNAUTHORIZED'
        });
    }

    const token = authHeader.split('Bearer ')[1];

    try {
        const decodedToken = await admin.auth().verifyIdToken(token);
        req.user = decodedToken; // uid, email vb. bilgiler burada
        next();
    } catch (error) {
        console.error('Auth Middleware Error:', error.message);
        return res.status(403).json({
            error: 'Geçersiz veya süresi dolmuş token.',
            code: 'FORBIDDEN'
        });
    }
};
