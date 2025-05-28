import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import Button from "../ui/button/Button";

const Perfil = () => {
  const [cliente, setCliente] = useState<any>(null);
  const [mensaje, setMensaje] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const fetchPerfil = async () => {
      const token = localStorage.getItem("token");

      const res = await fetch("http://localhost:5000/api/auth/perfil", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      const data = await res.json();

      if (!res.ok) {
        setMensaje(data.error || "No autorizado");
        return;
      }

      setCliente(data.cliente);
    };

    fetchPerfil();
  }, []);

  const logout = () => {
    localStorage.removeItem("token");
    navigate("/login");
  };

  if (mensaje) return <p>{mensaje}</p>;
  if (!cliente) return <p>Cargando...</p>;

  return (
    <div>
      <h2>Perfil</h2>
      <p><strong>CI:</strong> {cliente.ci_cliente}</p>
      <p><strong>Usuario:</strong> {cliente.usuario}</p>
      <Button handleClick={logout}>Cerrar sesión</Button>
    </div>
  );
};

export default Perfil;
