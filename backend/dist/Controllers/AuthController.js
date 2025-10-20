"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.perfil = exports.login = void 0;
const supabase_1 = require("../src/Config/supabase");
const jwt_1 = require("../src/utils/jwt");
const login = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { usuario, password } = req.body;
        if (!usuario || !password) {
            res.status(400).json({ error: 'Usuario y contraseña requeridos' });
            return;
        }
        const { data, error } = yield supabase_1.supabase
            .from('cliente')
            .select('*')
            .eq('usuario', usuario)
            .single();
        if (error || !data) {
            res.status(401).json({ error: 'Usuario no encontrado' });
            return;
        }
        const cliente = {
            ci_cliente: data.ci_cliente,
            idPersona: data.id_persona,
            usuario: data.usuario,
            password: data.password,
        };
        const passwordValido = password === cliente.password;
        if (!passwordValido) {
            res.status(401).json({ error: 'Contraseña incorrecta' });
            return;
        }
        const token = (0, jwt_1.generateToken)({
            ci_cliente: cliente.ci_cliente,
            usuario: cliente.usuario,
        });
        res.status(200).json({ token });
    }
    catch (err) {
        res.status(500).json({ error: 'Error en el servidor' });
    }
});
exports.login = login;
const perfil = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const user = req.user;
        res.status(200).json({
            mensaje: 'Ruta protegida',
            cliente: user,
        });
    }
    catch (e) {
        res.status(500).json({ error: "error en el servidor" });
    }
});
exports.perfil = perfil;
