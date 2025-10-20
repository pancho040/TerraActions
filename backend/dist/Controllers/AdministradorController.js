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
exports.AdministradorController = void 0;
const supabase_1 = require("../src/Config/supabase");
class AdministradorController {
    static getAll(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { data, error } = yield supabase_1.supabase.from("administrador").select("*");
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                res.status(500).json({ error: "Error al obtener administradores" });
            }
        });
    }
    static getById(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { ci } = req.params;
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("administrador")
                    .select("*")
                    .eq("administrador_de_ci", ci)
                    .single();
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                res.status(500).json({ error: "No se encontró el administrador" });
            }
        });
    }
    static create(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const newAdmin = req.body;
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("administrador")
                    .insert(newAdmin)
                    .single();
                if (error)
                    throw error;
                res.status(201).json(data);
            }
            catch (e) {
                res.status(500).json({ error: "No se pudo crear el administrador" });
            }
        });
    }
    static update(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { ci } = req.params;
            const updateData = req.body;
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("administrador")
                    .update(updateData)
                    .eq("administrador_de_ci", ci);
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                res.status(500).json({ error: "No se pudo actualizar" });
            }
        });
    }
    static delete(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { ci } = req.params;
            try {
                const { error } = yield supabase_1.supabase
                    .from("administrador")
                    .delete()
                    .eq("administrador_de_ci", ci);
                if (error)
                    throw error;
                res.status(200).json({ mensaje: "Administrador eliminado" });
            }
            catch (e) {
                res.status(500).json({ error: "No se pudo eliminar" });
            }
        });
    }
}
exports.AdministradorController = AdministradorController;
