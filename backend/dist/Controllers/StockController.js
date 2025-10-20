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
exports.StockController = void 0;
const supabase_1 = require("../src/Config/supabase");
class StockController {
    static getStock(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { data, error } = yield supabase_1.supabase.from("stock").select("*");
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al obtener el stock" });
            }
        });
    }
    static getStockDisponible(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("stock")
                    .select("*")
                    .eq("disponibilidad", true);
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al obtener stock disponible" });
            }
        });
    }
    static getStockById(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            const intId = parseInt(id, 10);
            if (isNaN(intId)) {
                res.status(400).json({ error: "ID de stock inválido" });
                return;
            }
            try {
                const { data, error } = yield supabase_1.supabase
                    .from("stock")
                    .select("*")
                    .eq("id_stock", intId)
                    .single();
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al obtener el stock" });
            }
        });
    }
}
exports.StockController = StockController;
