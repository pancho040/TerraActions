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
exports.SignupController = void 0;
const supabase_1 = require("../src/Config/supabase");
class SignupController {
    static signUp(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const personaData = {
                nombre: req.body.nombre,
                apellido: req.body.apellido,
                email: req.body.email,
                telefono: req.body.telefono,
                direccion: req.body.direccion,
                genero: req.body.genero
            };
            const clienteData = {
                ci_cliente: req.body.ci_cliente,
                usuario: req.body.usuario,
                password: req.body.password
            };
            if (!personaData.nombre || !personaData.apellido || !personaData.email ||
                !clienteData.ci_cliente || !clienteData.usuario || !clienteData.password) {
                res.status(400).json({ error: "Faltan datos obligatorios" });
                return;
            }
            try {
                const { data: newPersona, error: personaError } = yield supabase_1.supabase
                    .from("persona")
                    .insert(personaData)
                    .select("id_persona")
                    .single();
                if (personaError || !newPersona) {
                    console.error("Error en inserción de persona:", personaError);
                    res.status(400).json({
                        error: "Error al crear persona",
                        details: (personaError === null || personaError === void 0 ? void 0 : personaError.message) || "No se devolvieron datos"
                    });
                    return;
                }
                const completeClienteData = Object.assign(Object.assign({}, clienteData), { idPersona: newPersona.id_persona });
                const { data: newCliente, error: clienteError } = yield supabase_1.supabase
                    .from("cliente")
                    .insert({
                    ci_cliente: completeClienteData.ci_cliente,
                    id_persona: completeClienteData.idPersona,
                    usuario: completeClienteData.usuario,
                    password: completeClienteData.password
                })
                    .select()
                    .single();
                if (clienteError || !newCliente) {
                    yield supabase_1.supabase
                        .from("persona")
                        .delete()
                        .eq("id_persona", newPersona.id_persona);
                    res.status(400).json({
                        error: "El nombre del usuario ya existe intente nuevamente",
                        details: (clienteError === null || clienteError === void 0 ? void 0 : clienteError.message) || "No se devolvieron datos"
                    });
                    return;
                }
                res.status(201).json({
                    message: "Cliente creado exitosamente",
                    cliente: newCliente,
                    persona: newPersona
                });
            }
            catch (error) {
                console.error("Error en el servidor:", error);
                res.status(500).json({
                    error: "Error en el servidor",
                    details: error instanceof Error ? error.message : String(error)
                });
            }
        });
    }
    static getCliente(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("cliente")
                    .select(`
          *,
          persona: id_persona (*)
        `);
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error("Error al obtener clientes:", e);
                res.status(500).json({
                    error: "Fallo al obtener clientes",
                    details: e instanceof Error ? e.message : String(e)
                });
            }
        });
    }
}
exports.SignupController = SignupController;
