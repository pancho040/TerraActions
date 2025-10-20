import type { FC } from "react";
import "./Input.css";

type Props = {
  placeholder?: string;
  handleInput: (value: string | boolean | number | File | Date) => void;
  type:
    | "text"
    | "password"
    | "email"
    | "tel"
    | "number"
    | "file"
    | "date"
    | "time"
    | "checkbox"
    | "radio";
  resetMessage: () => void;
  autocomplete?: "email" | "current-password" | "new-password";
  value: string | boolean | number | Date;
  min?: number;
  max?: number;
};

const Input: FC<Props> = ({
  placeholder,
  handleInput,
  type,
  resetMessage,
  autocomplete,
  value,
  min,
  max,
}) => {
  function handleResult(value: string | boolean | number | File | Date) {
    resetMessage();
    handleInput(value);
  }

  // Convierte Date a string en formato YYYY-MM-DD si es necesario
  const getInputValue = () => {
    if (value instanceof Date) {
      return value.toISOString().split("T")[0];
    }
    if (typeof value === "string" || typeof value === "number") {
      return value;
    }
    return "";
  };

  return (
    <input
      autoComplete={autocomplete ?? ""}
      className="input"
      type={type}
      placeholder={placeholder ?? ""}
      checked={typeof value === "boolean" ? value : undefined}
      {...(type === "number" && min !== undefined ? { min } : {})}
      {...(type === "number" && max !== undefined ? { max } : {})}
      {...(type !== "file" && type !== "checkbox" && type !== "radio"
        ? { value: getInputValue() }
        : {})}
      onInput={(e) => {
        if (type === "checkbox" || type === "radio") return;
        const target = e.target as HTMLInputElement;
        handleResult(target.value);
      }}
      onChange={(e) => {
        const target = e.target as HTMLInputElement;

        if (type === "file" && target.files && target.files.length > 0) {
          handleResult(target.files.item(0)!);
          return;
        }

        if (type === "checkbox" || type === "radio") {
          handleResult(target.checked);
          return;
        }

        if (type === "number") {
          handleResult(target.value === "" ? 0 : parseFloat(target.value));
          return;
        }

        if (type === "date" || type === "time") {
          handleResult(new Date(target.value));
          return;
        }

        // Para todos los demás tipos: text, password, email, tel
        handleResult(target.value);
      }}
    />
  );
};

export default Input;