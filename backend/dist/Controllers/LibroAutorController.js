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
exports.LibroAutorController = void 0;
const supabase_1 = require("../src/Config/supabase");
class LibroAutorController {
    static getLibrosConAutoresYSinopsis(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { data, error } = yield supabase_1.supabase
                    .from('libro')
                    .select(`
                    titulo,
                    sinopsis,
                    libro_autor(id_autor, autor(nombre))
                `);
                if (error)
                    throw error;
                const result = data.map(libro => ({
                    titulo: libro.titulo,
                    sinopsis: libro.sinopsis,
                    autores: libro.libro_autor.map((la) => la.autor.nombre)
                }));
                res.status(200).json(result);
            }
            catch (error) {
                console.error('Error:', error);
                res.status(500).json({ error: 'Error al obtener datos de libros' });
            }
        });
    }
    static getAutoresBio(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { data, error } = yield supabase_1.supabase
                    .from('autor')
                    .select(`
                    nombre,
                    biografia,
                    fecha_nac,
                    fecha_muerte,
                    nacionalidad
                `)
                    .order('nombre', { ascending: true });
                if (error)
                    throw error;
                const autores = data.map(autor => ({
                    nombre: autor.nombre,
                    biografia: autor.biografia,
                    fecha_nacimiento: autor.fecha_nac,
                    fecha_muerte: autor.fecha_muerte,
                    nacionalidad: autor.nacionalidad
                }));
                res.status(200).json(autores);
            }
            catch (error) {
                console.error('Error al obtener biografías de autores:', error);
                res.status(500).json({
                    error: 'Error al obtener biografías de autores',
                    details: error instanceof Error ? error.message : 'Error desconocido'
                });
            }
        });
    }
}
exports.LibroAutorController = LibroAutorController;
