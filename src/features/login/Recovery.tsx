"use client"

import { recoverService } from "../../api/services/userService"
import type React from "react"
import { useState } from "react"
import { Link } from "react-router-dom"
import { Mail, CheckCircle, ArrowLeft, KeyRound, Send, UserPlus } from "lucide-react"
import { Alert } from "../../components/UI/Alert"
import "./Login.css"

interface AlertState {
  show: boolean
  type: "success" | "error" | "info" | "warning"
  message: string
}

export function Recovery() {
  const [submitting, setSubmitting] = useState(false)
  const [password, setPassword] = useState("")
  const [email, setEmail] = useState("")
  const [alert, setAlert] = useState<AlertState>({ show: false, type: "info", message: "" })
  const [isSuccess, setIsSuccess] = useState(false)

  const showAlert = (type: AlertState["type"], message: string) => {
    setAlert({ show: true, type, message })
  }

  const hideAlert = () => {
    setAlert({ show: false, type: "info", message: "" })
  }

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    hideAlert()
    setSubmitting(true)

    try {
      const response = await recoverService(email)
      if (response.error || response.Error) {
        showAlert("error", response.error || response.Error || "Error al enviar el correo de recuperación")
      } else if (response.message || response.Message) {
        showAlert("success", response.message || response.Message)
        setPassword(response.TemporaryPassword)
        setIsSuccess(true)
      } else {
        showAlert("error", "Respuesta inesperada del servidor")
      }
    } catch (err: any) {
      showAlert("error", err.message || "Error inesperado al procesar la solicitud")
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="app-container">
      <div className="auth-container">
        {alert.show && <Alert type={alert.type} message={alert.message} onClose={hideAlert} />}
        <div className="auth-card animate-slide-up">
          <div className="auth-header">
            <div className="auth-logo">
              <KeyRound size={24} />
            </div>
            <h1>Recuperar Contraseña</h1>
            <p>{isSuccess ? "Revisa tu correo electrónico" : "Ingresa tu correo para recibir instrucciones"}</p>
          </div>

          {!isSuccess ? (
            <form className="auth-form" onSubmit={handleSubmit}>
              <div className="form-group">
                <label htmlFor="email">Correo Electrónico</label>
                <div className="input-container">
                  <Mail className="input-icon" size={16} />
                  <input
                    id="email"
                    type="email"
                    placeholder="correo@empresa.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                  />
                </div>
              </div>

              <button
                type="submit"
                className={`auth-button primary ${submitting ? "loading" : ""}`}
                disabled={submitting}
              >
                {submitting ? (
                  <>
                    <span className="button-spinner"></span>
                    Enviando...
                  </>
                ) : (
                  <>
                    <Send size={16} />
                    Enviar Instrucciones
                  </>
                )}
              </button>
            </form>
          ) : (
            <div className="auth-success animate-fade-in">
              <CheckCircle size={48} className="success-icon" />
              <h3>¡Contraseña restablecida!</h3>
              <p>Tu nueva contraseña temporal es:</p>
              <div
                style={{
                  background: "var(--bg-muted)",
                  padding: "12px",
                  borderRadius: "6px",
                  fontFamily: "monospace",
                  fontSize: "16px",
                  fontWeight: "600",
                  color: "var(--primary)",
                  margin: "12px 0",
                  border: "1px solid var(--border)",
                }}
              >
                {password}
              </div>
              <p style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                Cambia esta contraseña después de iniciar sesión
              </p>
            </div>
          )}

          <div className="auth-divider">
            <span>o</span>
          </div>

          <div className="auth-actions">
            <Link to="/auth/login" className="auth-button outline">
              <ArrowLeft size={16} />
              Volver al inicio de sesión
            </Link>
            {!isSuccess && (
              <Link to="/auth/register" className="auth-button secondary">
                <UserPlus size={16} />
                Crear cuenta nueva
              </Link>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
