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
exports.PersonaController = void 0;
const supabase_1 = require("../src/Config/supabase");
class PersonaController {
    static getPersona(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { data, error } = yield supabase_1.supabase.from("persona").select("*");
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al obtener personas" });
            }
        });
    }
    static getPersonaById(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            const intId = parseInt(id, 10);
            if (isNaN(intId)) {
                res.status(400).json({ error: "ID inválido" });
                return;
            }
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("persona")
                    .select("*")
                    .eq("id_persona", intId)
                    .single();
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al obtener persona por ID" });
            }
        });
    }
    static createPersona(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const np = req.body;
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("persona")
                    .insert(np)
                    .single();
                if (error)
                    throw error;
                res.status(201).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al crear persona" });
            }
        });
    }
    static updatePersona(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            const intId = parseInt(id, 10);
            const pUp = req.body;
            if (isNaN(intId)) {
                res.status(400).json({ error: "ID inválido" });
                return;
            }
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("persona")
                    .update(pUp)
                    .eq("id_persona", intId)
                    .single();
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al actualizar persona" });
            }
        });
    }
    static deletePersona(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            const intId = parseInt(id, 10);
            if (isNaN(intId)) {
                res.status(400).json({ error: "ID inválido" });
                return;
            }
            try {
                const { error } = yield supabase_1.supabase
                    .from("persona")
                    .delete()
                    .eq("id_persona", intId);
                if (error)
                    throw error;
                res.status(200).json({ mensaje: "Persona eliminada exitosamente" });
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al eliminar persona" });
            }
        });
    }
}
exports.PersonaController = PersonaController;
