"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const AuthController_1 = require("../Controllers/AuthController");
const authMiddleWare_1 = require("../Middlewares/authMiddleWare");
const loginRouter = (0, express_1.Router)();
loginRouter.post('/login', AuthController_1.login);
loginRouter.get('/perfil', authMiddleWare_1.authMiddleware, AuthController_1.perfil);
exports.default = loginRouter;
