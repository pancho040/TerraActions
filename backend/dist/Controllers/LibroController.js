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
exports.LibroController = void 0;
const supabase_1 = require("../src/Config/supabase");
class LibroController {
    static getLibro(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { data, error } = yield supabase_1.supabase.from("libro").select("*");
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al obtener clientes" });
            }
        });
    }
    static getLibroId(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("libro")
                    .select("*")
                    .eq("id_libro", id)
                    .single();
                if (error)
                    throw error;
                res.status(200).json({ data: data, message: "Libro obtenido correctamente" });
            }
            catch (error) {
                console.log(error);
                res.status(500).json({ error: "fallo al obtener el libro" });
            }
        });
    }
    static getLibroPorTitulo(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { titulo } = req.params;
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("libro")
                    .select("*")
                    .ilike("titulo", `%${titulo}%`);
                if (error)
                    throw error;
                if (data && data.length === 0) {
                    res.status(404).json({ message: "No se encontraron libros con ese título" });
                }
                else {
                    res.status(200).json({ data: data, message: "Libros encontrados" });
                }
            }
            catch (error) {
                console.log(error);
                res.status(500).json({ error: "Error al buscar libros por título" });
            }
        });
    }
    static getLibroPorGenero(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { genero } = req.params;
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("libro")
                    .select("*")
                    .ilike("genero", `%${genero}%`);
                if (error)
                    throw error;
                if (data && data.length === 0) {
                    res.status(404).json({
                        message: `No se encontraron libros del género '${genero}'`
                    });
                }
                else {
                    res.status(200).json({
                        data: data,
                        message: `Libros del género '${genero}' encontrados`
                    });
                }
            }
            catch (error) {
                console.log(error);
                res.status(500).json({
                    error: "Error al buscar libros por género"
                });
            }
        });
    }
}
exports.LibroController = LibroController;
