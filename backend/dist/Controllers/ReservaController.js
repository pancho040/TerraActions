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
exports.ReservaController = void 0;
const supabase_1 = require("../src/Config/supabase");
class ReservaController {
    static getReservas(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { data, error } = yield supabase_1.supabase.from("reserva").select("*");
                if (error)
                    throw error;
                res.status(200).json(data);
            }
            catch (e) {
                console.error(e);
                res.status(500).json({ error: "Fallo al obtener reservas" });
            }
        });
    }
    static crearReservaDirecta(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id_libro, ci_cliente } = req.body;
            if (!id_libro || !ci_cliente) {
                res.status(400).json({
                    success: false,
                    message: 'Los campos id_libro y ci_cliente son requeridos'
                });
                return;
            }
            try {
                const { data: libroDisponible, error: errorStock } = yield supabase_1.supabase
                    .from('stock')
                    .select('id_stock')
                    .eq('id_libro', id_libro)
                    .eq('disponibilidad', true)
                    .limit(1);
                if (errorStock)
                    throw errorStock;
                if (!libroDisponible || libroDisponible.length === 0) {
                    res.status(400).json({
                        success: false,
                        message: 'El libro no está disponible para reserva'
                    });
                    return;
                }
                const id_stock = libroDisponible[0].id_stock;
                const { data: nuevaReserva, error: errorReserva } = yield supabase_1.supabase
                    .from('reserva')
                    .insert({
                    fec_reserva: new Date(),
                    fec_prestamo: new Date(),
                    fec_limite: new Date()
                })
                    .select('id_reserva')
                    .single();
                if (errorReserva)
                    throw errorReserva;
                const id_reserva = nuevaReserva.id_reserva;
                const { error: errorDetalle } = yield supabase_1.supabase
                    .from('detalle_reserva')
                    .insert({
                    id_reserva,
                    id_libro
                });
                if (errorDetalle)
                    throw errorDetalle;
                const { error: errorUpdateStock } = yield supabase_1.supabase
                    .from('stock')
                    .update({
                    disponibilidad: false,
                })
                    .eq('id_stock', id_stock);
                if (errorUpdateStock)
                    throw errorUpdateStock;
                const { error: errorCliMulRes } = yield supabase_1.supabase
                    .from('cli_mul_res')
                    .insert({
                    ci_cliente,
                    id_reserva
                });
                if (errorCliMulRes)
                    throw errorCliMulRes;
                res.status(201).json({
                    success: true,
                    message: 'Reserva creada exitosamente',
                    data: {
                        id_reserva,
                        id_libro,
                        ci_cliente
                    }
                });
            }
            catch (error) {
                console.error('Error en crearReservaDirecta:', error);
                res.status(500).json({
                    success: false,
                    message: 'Error al crear la reserva',
                    error: error instanceof Error ? error.message : 'Error desconocido'
                });
            }
        });
    }
    static getLibroStockDisponibles(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { data, error } = yield supabase_1.supabase
                    .from('libro')
                    .select('*, stock!inner(*)')
                    .eq('stock.disponibilidad', true);
                if (error)
                    throw error;
                res.status(200).json({
                    success: true,
                    count: data.length,
                    data: data
                });
            }
            catch (error) {
                res.status(500).json({
                    success: false,
                    message: 'Error al obtener libros disponibles',
                    error: error instanceof Error ? error.message : 'Error desconocido'
                });
            }
        });
    }
}
exports.ReservaController = ReservaController;
