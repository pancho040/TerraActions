"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const signupController_1 = require("../Controllers/signupController");
const signUpRouter = (0, express_1.Router)();
signUpRouter.post("/", signupController_1.SignupController.signUp);
signUpRouter.get("/", signupController_1.SignupController.getCliente);
exports.default = signUpRouter;
