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
exports.MultaController = void 0;
const supabase_1 = require("../src/Config/supabase");
class MultaController {
    static getMulta(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { data, error } = yield supabase_1.supabase.from("multa").select("*");
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al obtener las multas" });
            }
        });
    }
    static getMultaById(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            const intId = parseInt(id, 10);
            if (isNaN(intId)) {
                res.status(400).json({ error: "ID inválido" });
                return;
            }
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("multa")
                    .select("*")
                    .eq("id_multa", intId)
                    .single();
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al obtener la multa" });
            }
        });
    }
    static createMulta(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { monto, motivo, estado } = req.body;
            if (monto == null || !motivo || !estado) {
                res.status(400).json({ error: "Campos requeridos: monto, motivo, estado" });
                return;
            }
            const nuevaMulta = {
                monto,
                motivo,
                estado,
                fecha_creacion: new Date(),
                fecha_actualizacion: new Date(),
            };
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("multa")
                    .insert(nuevaMulta)
                    .select()
                    .single();
                if (error)
                    throw error;
                res.status(201).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al crear la multa" });
            }
        });
    }
    static updateMulta(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            const intId = parseInt(id, 10);
            const { monto, motivo, estado } = req.body;
            if (isNaN(intId)) {
                res.status(400).json({ error: "ID inválido" });
                return;
            }
            const multaActualizada = Object.assign(Object.assign(Object.assign({}, (monto !== undefined && { monto })), (motivo !== undefined && { motivo })), (estado !== undefined && { estado }));
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("multa")
                    .update(multaActualizada)
                    .eq("id_multa", intId)
                    .select()
                    .single();
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al actualizar la multa" });
            }
        });
    }
    static deleteMulta(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            const intId = parseInt(id, 10);
            if (isNaN(intId)) {
                res.status(400).json({ error: "ID inválido" });
                return;
            }
            try {
                const { error } = yield supabase_1.supabase
                    .from("multa")
                    .delete()
                    .eq("id_multa", intId);
                if (error)
                    throw error;
                res.status(200).json({ mensaje: "Multa eliminada exitosamente" });
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al eliminar la multa" });
            }
        });
    }
}
exports.MultaController = MultaController;
