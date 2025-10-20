"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const ReservaController_1 = require("../Controllers/ReservaController");
const reservaRouter = (0, express_1.Router)();
reservaRouter.get("/", ReservaController_1.ReservaController.getReservas);
reservaRouter.get("/catalogo/disponibles", ReservaController_1.ReservaController.getLibroStockDisponibles);
reservaRouter.post("/directa", ReservaController_1.ReservaController.crearReservaDirecta);
exports.default = reservaRouter;
