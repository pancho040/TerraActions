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
exports.AutorController = void 0;
const supabase_1 = require("../src/Config/supabase");
class AutorController {
    static getAutor(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { data, error } = yield supabase_1.supabase.from("autor").select("*");
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al obtener los autores" });
            }
        });
    }
    static getAutorById(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            const intId = parseInt(id, 10);
            if (isNaN(intId)) {
                res.status(400).json({ error: "ID inválido" });
                return;
            }
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("autor")
                    .select("*")
                    .eq("id_autor", intId)
                    .single();
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al obtener autor por ID" });
            }
        });
    }
    static createAutor(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const nuevoAutor = req.body;
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("autor")
                    .insert(nuevoAutor)
                    .single();
                if (error)
                    throw error;
                res.status(201).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al crear autor" });
            }
        });
    }
    static updateAutor(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            const intId = parseInt(id, 10);
            const autorActualizado = req.body;
            if (isNaN(intId)) {
                res.status(400).json({ error: "ID inválido" });
                return;
            }
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("autor")
                    .update(autorActualizado)
                    .eq("id_autor", intId);
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al actualizar autor" });
            }
        });
    }
    static deleteAutor(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            const intId = parseInt(id, 10);
            if (isNaN(intId)) {
                res.status(400).json({ error: "ID inválido" });
                return;
            }
            try {
                const { error } = yield supabase_1.supabase
                    .from("autor")
                    .delete()
                    .eq("id_autor", intId);
                if (error)
                    throw error;
                res.status(200).json({ mensaje: "Autor eliminado exitosamente" });
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al eliminar autor" });
            }
        });
    }
    static getPorNombre(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { nombre } = req.params;
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("autor")
                    .select("*")
                    .ilike("nombre", `%${nombre}%`);
                if (error)
                    throw error;
                if (!data || data.length === 0) {
                    res.status(404).json({
                        message: `No se encontraron autores con el nombre "${nombre}"`
                    });
                }
                else {
                    res.status(200).json({
                        data,
                        message: `Autores con el nombre "${nombre}" encontrados`
                    });
                }
            }
            catch (error) {
                console.error(error);
                res.status(500).json({
                    error: "Error al buscar autores por nombre"
                });
            }
        });
    }
}
exports.AutorController = AutorController;
