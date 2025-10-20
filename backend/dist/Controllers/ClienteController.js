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
exports.ClienteController = void 0;
const supabase_1 = require("../src/Config/supabase");
class ClienteController {
    static getCliente(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { data, error } = yield supabase_1.supabase.from("cliente").select("*");
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
    static getClienteId(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { ci } = req.params;
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("cliente")
                    .select("*")
                    .eq("ci_cliente", ci)
                    .single();
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "No se encontró el ci del cliente" });
            }
        });
    }
    static createCliente(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const nClient = req.body;
            try {
                const { data: persona, error: personaError } = yield supabase_1.supabase
                    .from("persona")
                    .select("id_persona")
                    .eq("id_persona", nClient.idPersona)
                    .single();
                if (personaError || !persona) {
                    res.status(400).json({ error: "La persona asociada no existe" });
                    return;
                }
                const { data, error } = yield supabase_1.supabase
                    .from("cliente")
                    .insert({
                    ci_cliente: nClient.ci_cliente,
                    id_persona: nClient.idPersona,
                    usuario: nClient.usuario,
                    password: nClient.password,
                })
                    .single();
                if (error)
                    throw error;
                res.status(201).json({ data: data, message: "Persona creada exitosamente" });
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al crear cliente" });
            }
        });
    }
    static updateCliente(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { ci } = req.params;
            const cUp = req.body;
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("cliente")
                    .update({
                    usuario: cUp.usuario,
                    password: cUp.password,
                })
                    .eq("ci_cliente", ci);
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al actualizar el cliente" });
            }
        });
    }
    static deleteCliente(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { ci } = req.params;
            try {
                const { error } = yield supabase_1.supabase
                    .from("cliente")
                    .delete()
                    .eq("ci_cliente", ci);
                if (error)
                    throw error;
                res.status(200).json({ mensaje: "Cliente eliminado exitosamente" });
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al eliminar cliente" });
            }
        });
    }
}
exports.ClienteController = ClienteController;
