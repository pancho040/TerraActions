"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateToken = generateToken;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
function generateToken(payload) {
    return jsonwebtoken_1.default.sign(payload, process.env.JWT_SECRET || 'secret', {
        expiresIn: '30m',
    });
}
