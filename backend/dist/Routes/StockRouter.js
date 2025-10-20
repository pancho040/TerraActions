"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const StockController_1 = require("../Controllers/StockController");
const stockRouter = (0, express_1.Router)();
stockRouter.get("/", StockController_1.StockController.getStock);
stockRouter.get("/disponible", StockController_1.StockController.getStockDisponible);
stockRouter.get("/:id", StockController_1.StockController.getStockById);
exports.default = stockRouter;
