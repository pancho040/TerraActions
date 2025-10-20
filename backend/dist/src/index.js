"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv_1 = __importDefault(require("dotenv"));
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const MultaRouter_1 = __importDefault(require("../Routes/MultaRouter"));
const ReservaRouter_1 = __importDefault(require("../Routes/ReservaRouter"));
const AutorRouter_1 = __importDefault(require("../Routes/AutorRouter"));
const PersonaRoutes_1 = __importDefault(require("../Routes/PersonaRoutes"));
const authRouter_1 = __importDefault(require("../Routes/authRouter"));
const LibroRouter_1 = __importDefault(require("../Routes/LibroRouter"));
const AdministradorRouter_1 = __importDefault(require("../Routes/AdministradorRouter"));
const ClienteRouter_1 = __importDefault(require("../Routes/ClienteRouter"));
const StockRouter_1 = __importDefault(require("../Routes/StockRouter"));
const signUpRouter_1 = __importDefault(require("../Routes/signUpRouter"));
const LibroAutorRouter_1 = __importDefault(require("../Routes/LibroAutorRouter"));
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = Number(process.env.PORT) || 5000;
// CORS CONFIGURADO
app.use((0, cors_1.default)({
    origin: [
        'http://localhost:5173',
        'http://localhost:5174',
        'http://127.0.0.1:5173',
        process.env.FRONT_SSH_HOST ? `http://${process.env.FRONT_SSH_HOST}` : '',
        process.env.FRONT_SSH_HOST ? `https://${process.env.FRONT_SSH_HOST}` : '',
        process.env.FRONTEND_URL || ''
    ].filter(Boolean),
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    exposedHeaders: ['Authorization']
}));
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
// Log de peticiones
app.use((req, _res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});
// Rutas
app.use('/api/persona', PersonaRoutes_1.default);
app.use('/api/multa', MultaRouter_1.default);
app.use('/api/reserva', ReservaRouter_1.default);
app.use('/api/administrador', AdministradorRouter_1.default);
app.use('/api/cliente', ClienteRouter_1.default);
app.use('/api/autor', AutorRouter_1.default);
app.use('/api/auth', authRouter_1.default);
app.use('/api/libro', LibroRouter_1.default);
app.use('/api/signup', signUpRouter_1.default);
app.use('/api/stock', StockRouter_1.default);
app.use('/api/LA', LibroAutorRouter_1.default);
console.log("Ruta /api/stock cargada correctamente");
// Ruta de health check
app.get('/api', (_req, res) => {
    res.json({
        message: "Hola desde Express!",
        status: "ok",
        environment: process.env.NODE_ENV,
        timestamp: new Date().toISOString()
    });
});
app.get('/api/health', (_req, res) => {
    res.json({
        status: 'healthy',
        uptime: process.uptime(),
        frontendHost: process.env.FRONT_SSH_HOST,
        port: PORT
    });
});
// Manejo de rutas no encontradas
app.use('*', (req, res) => {
    res.status(404).json({
        error: 'Ruta no encontrada',
        path: req.originalUrl
    });
});
// Manejo de errores global
app.use((err, req, res, _next) => {
    console.error('❌ Error:', err);
    res.status(err.status || 500).json({
        error: err.message || 'Error interno del servidor',
        path: req.path
    });
});
// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Servidor corriendo en http://0.0.0.0:${PORT}`);
    console.log(`📍 Entorno: ${process.env.NODE_ENV || 'development'}`);
    console.log(`🌐 CORS habilitado para:`);
    console.log(`   - http://localhost:5173 (desarrollo)`);
    if (process.env.FRONT_SSH_HOST) {
        console.log(`   - http://${process.env.FRONT_SSH_HOST} (producción)`);
    }
    console.log(`⏰ Iniciado: ${new Date().toISOString()}`);
});
exports.default = app;
