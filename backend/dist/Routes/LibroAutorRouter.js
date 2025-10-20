"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const LibroAutorController_1 = require("../Controllers/LibroAutorController");
const express_1 = require("express");
const libroAutorRouter = (0, express_1.Router)();
libroAutorRouter.get("/sinopsis", LibroAutorController_1.LibroAutorController.getLibrosConAutoresYSinopsis);
libroAutorRouter.get("/bio", LibroAutorController_1.LibroAutorController.getAutoresBio);
exports.default = libroAutorRouter;
