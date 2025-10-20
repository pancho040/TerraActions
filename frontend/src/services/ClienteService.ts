import type { Cliente } from "../../../backend/Models/Cliente";
import { fetchApi } from "./api";

// Define el tipo para crear/actualizar cliente localmente
export interface ClienteInput {
  nombre: string;
  apellido: string;
  email: string;
  telefono: string;
  direccion: string;
  genero: string;
  ci_cliente: string;
  usuario: string;
  password: string;
}

export class ClienteService {
  static async getAll(): Promise<Cliente[]> {
    return fetchApi("/cliente");
  }

  static async getById(id: number): Promise<Cliente> {
    return fetchApi(`/cliente/${id}`);
  }

  static async create(cliente: ClienteInput): Promise<Cliente> {
    return fetchApi("/cliente", {
      method: "POST",
      body: JSON.stringify(cliente),
    });
  }

  static async update(id: number, cliente: ClienteInput): Promise<Cliente> {
    return fetchApi(`/cliente/${id}`, {
      method: "PUT",
      body: JSON.stringify(cliente),
    });
  }

  static async delete(id: number): Promise<void> {
    await fetchApi(`/cliente/${id}`, {
      method: "DELETE",
    });
  }
}