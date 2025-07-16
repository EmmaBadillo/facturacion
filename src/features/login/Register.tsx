"use client"

import { registerService } from "../../api/services/userService"
import type React from "react"
import { useState } from "react"
import { Link } from "react-router-dom"
import {
  User,
  Mail,
  Lock,
  Eye,
  EyeOff,
  Phone,
  MapPin,
  CreditCard,
  CheckCircle,
  ArrowLeft,
  UserPlus,
  KeyRound,
} from "lucide-react"
import { Alert } from "../../components/UI/Alert"
import "./Login.css"

interface AlertState {
  show: boolean
  type: "success" | "error" | "info" | "warning"
  message: string
}

interface FormData {
  firstName: string
  lastName: string
  email: string
  cedula: string
  phone: string
  address: string
  password: string
  confirmPassword: string
}

interface FormErrors {
  [key: string]: string
}

export function Register() {
  const [submitting, setSubmitting] = useState(false)
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const [alert, setAlert] = useState<AlertState>({ show: false, type: "info", message: "" })
  const [isSuccess, setIsSuccess] = useState(false)
  const [formData, setFormData] = useState<FormData>({
    firstName: "",
    lastName: "",
    email: "",
    cedula: "",
    phone: "",
    address: "",
    password: "",
    confirmPassword: "",
  })
  const [errors, setErrors] = useState<FormErrors>({})

  const showAlert = (type: AlertState["type"], message: string) => {
    setAlert({ show: true, type, message })
  }

  const hideAlert = () => {
    setAlert({ show: false, type: "info", message: "" })
  }

  // Validación de cédula ecuatoriana
  const validateEcuadorianCedula = (cedula: string): boolean => {
    if (!/^\d{10}$/.test(cedula)) return false

    const digits = cedula.split("").map(Number)
    const province = Number.parseInt(cedula.substring(0, 2))

    if (province < 1 || province > 24) return false
    if (digits[2] >= 6) return false

    const coefficients = [2, 1, 2, 1, 2, 1, 2, 1, 2]
    let sum = 0

    for (let i = 0; i < 9; i++) {
      let result = digits[i] * coefficients[i]
      if (result >= 10) {
        result = result - 9
      }
      sum += result
    }

    const verifierDigit = sum % 10 === 0 ? 0 : 10 - (sum % 10)
    return verifierDigit === digits[9]
  }

  // Validación de teléfonos celulares ecuatorianos
    const validateEcuadorianCellPhone = (phone: string): boolean => {
      // Debe empezar con 09 y tener 10 dígitos total
      if (!/^09\d{8}$/.test(phone)) return false

      // Validar operadores válidos en Ecuador
      const validOperators = ["098", "099", "096", "097", "095", "094", "093", "092"]
      const operator = phone.substring(0, 3)

      return validOperators.indexOf(operator) !== -1
    }

  // Validación de contraseña robusta
  const validatePassword = (password: string): { isValid: boolean; message: string } => {
    if (password.length < 6) {
      return { isValid: false, message: "La contraseña debe tener al menos 6 caracteres" }
    }

    if (password.length > 10) {
      return { isValid: false, message: "La contraseña no puede tener más de 10 caracteres" }
    }

    if (!/[A-Z]/.test(password)) {
      return { isValid: false, message: "Debe contener al menos una letra mayúscula" }
    }

    if (!/[a-z]/.test(password)) {
      return { isValid: false, message: "Debe contener al menos una letra minúscula" }
    }

    if (!/\d/.test(password)) {
      return { isValid: false, message: "Debe contener al menos un número" }
    }

    if (!/[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/.test(password)) {
      return { isValid: false, message: "Debe contener al menos un carácter especial (!@#$%^&*)" }
    }

    return { isValid: true, message: "" }
  }

  const validateForm = (): boolean => {
    const newErrors: FormErrors = {}

    if (!formData.firstName.trim()) newErrors.firstName = "El nombre es requerido"
    if (!formData.lastName.trim()) newErrors.lastName = "El apellido es requerido"
    if (!formData.email.trim()) newErrors.email = "El correo es requerido"
    if (!formData.cedula.trim()) newErrors.cedula = "La cédula es requerida"
    if (!formData.password) newErrors.password = "La contraseña es requerida"
    if (!formData.confirmPassword) newErrors.confirmPassword = "Confirma tu contraseña"

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (formData.email && !emailRegex.test(formData.email)) {
      newErrors.email = "Correo electrónico inválido"
    }

    if (formData.cedula && !validateEcuadorianCedula(formData.cedula)) {
      newErrors.cedula = "Cédula ecuatoriana inválida"
    }

    if (formData.phone && !validateEcuadorianCellPhone(formData.phone)) {
      newErrors.phone = "Número celular ecuatoriano inválido (ej: 098xxxxxxx)"
    }

    if (formData.password) {
      const passwordValidation = validatePassword(formData.password)
      if (!passwordValidation.isValid) {
        newErrors.password = passwordValidation.message
      }
    }

    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = "Las contraseñas no coinciden"
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    if (name === "cedula" || name === "phone") {
      const numericValue = value.replace(/\D/g, "")
      setFormData((prev) => ({ ...prev, [name]: numericValue }))
    } else {
      setFormData((prev) => ({ ...prev, [name]: value }))
    }

    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: "" }))
    }
  }

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    hideAlert()

    if (!validateForm()) {
      showAlert("error", "Por favor corrige los errores en el formulario")
      return
    }

    setSubmitting(true)

    try {
      const clientData = {
        firstName: formData.firstName.trim(),
        lastName: formData.lastName.trim(),
        email: formData.email.trim(),
        cedula: formData.cedula,
        phone: formData.phone || null,
        address: formData.address.trim() || null,
        password: formData.password,
      }

      const response = await registerService(clientData)

      if (response.error || response.Error || response.ERROR) {
        showAlert("error", response.error || response.Error || response.ERROR || "Error al crear la cuenta")
      } else if (response.message || response.Message) {
        showAlert("success", response.message || response.Message)
        setIsSuccess(true)
      } else {
        showAlert("error", "Respuesta inesperada del servidor")
      }
    } catch (err: any) {
      showAlert("error", err.message || "Error inesperado al crear la cuenta")
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="app-container">
      <div className="auth-container">
        {alert.show && <Alert type={alert.type} message={alert.message} onClose={hideAlert} />}
        <div className="auth-card large animate-slide-up">
          <div className="auth-header">
            <div className="auth-logo">
              <UserPlus size={24} />
            </div>
            <h1>Crear Cuenta</h1>
            <p>{isSuccess ? "¡Bienvenido! Tu cuenta ha sido creada" : "Completa tus datos para registrarte"}</p>
          </div>

          {!isSuccess ? (
            <form className="auth-form" onSubmit={handleSubmit}>
              <div className="form-grid">
                <div className="form-group">
                  <label htmlFor="firstName">Nombre *</label>
                  <div className="input-container">
                    <User className="input-icon" size={16} />
                    <input
                      id="firstName"
                      name="firstName"
                      type="text"
                      placeholder="Tu nombre"
                      value={formData.firstName}
                      onChange={handleInputChange}
                      required
                      className={errors.firstName ? "error" : ""}
                    />
                  </div>
                  {errors.firstName && <span className="field-error">{errors.firstName}</span>}
                </div>

                <div className="form-group">
                  <label htmlFor="lastName">Apellido *</label>
                  <div className="input-container">
                    <User className="input-icon" size={16} />
                    <input
                      id="lastName"
                      name="lastName"
                      type="text"
                      placeholder="Tu apellido"
                      value={formData.lastName}
                      onChange={handleInputChange}
                      required
                      className={errors.lastName ? "error" : ""}
                    />
                  </div>
                  {errors.lastName && <span className="field-error">{errors.lastName}</span>}
                </div>
              </div>

              <div className="form-group">
                <label htmlFor="email">Correo Electrónico *</label>
                <div className="input-container">
                  <Mail className="input-icon" size={16} />
                  <input
                    id="email"
                    name="email"
                    type="email"
                    placeholder="correo@empresa.com"
                    value={formData.email}
                    onChange={handleInputChange}
                    required
                    className={errors.email ? "error" : ""}
                  />
                </div>
                {errors.email && <span className="field-error">{errors.email}</span>}
              </div>

              <div className="form-grid">
                <div className="form-group">
                  <label htmlFor="cedula">Cédula Ecuatoriana *</label>
                  <div className="input-container">
                    <CreditCard className="input-icon" size={16} />
                    <input
                      id="cedula"
                      name="cedula"
                      type="text"
                      placeholder="1234567890"
                      value={formData.cedula}
                      onChange={handleInputChange}
                      maxLength={10}
                      required
                      className={errors.cedula ? "error" : ""}
                    />
                  </div>
                  {errors.cedula && <span className="field-error">{errors.cedula}</span>}
                </div>

                <div className="form-group">
                  <label htmlFor="phone">Celular</label>
                  <div className="input-container">
                    <Phone className="input-icon" size={16} />
                    <input
                      id="phone"
                      name="phone"
                      type="text"
                      placeholder="0987654321"
                      value={formData.phone}
                      onChange={handleInputChange}
                      maxLength={10}
                      className={errors.phone ? "error" : ""}
                    />
                  </div>
                  {errors.phone && <span className="field-error">{errors.phone}</span>}
                </div>
              </div>

              <div className="form-group">
                <label htmlFor="address">Dirección</label>
                <div className="input-container">
                  <MapPin className="input-icon" size={16} />
                  <input
                    id="address"
                    name="address"
                    type="text"
                    placeholder="Tu dirección (opcional)"
                    value={formData.address}
                    onChange={handleInputChange}
                  />
                </div>
              </div>

              <div className="form-grid">
                <div className="form-group">
                  <label htmlFor="password">Contraseña *</label>
                  <div className="input-container">
                    <Lock className="input-icon" size={16} />
                    <input
                      id="password"
                      name="password"
                      type={showPassword ? "text" : "password"}
                      placeholder="Contraseña"
                      value={formData.password}
                      onChange={handleInputChange}
                      maxLength={10}
                      required
                      className={errors.password ? "error" : ""}
                    />
                    <button
                      type="button"
                      className="password-toggle"
                      onClick={() => setShowPassword(!showPassword)}
                      aria-label={showPassword ? "Ocultar contraseña" : "Mostrar contraseña"}
                    >
                      {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                    </button>
                  </div>
                  {errors.password && <span className="field-error">{errors.password}</span>}
                  <div className="password-requirements">
                    <small style={{ color: "var(--text-muted)", fontSize: "11px" }}>
                      6-10 caracteres, mayúscula, minúscula, número y carácter especial
                    </small>
                  </div>
                </div>

                <div className="form-group">
                  <label htmlFor="confirmPassword">Confirmar *</label>
                  <div className="input-container">
                    <Lock className="input-icon" size={16} />
                    <input
                      id="confirmPassword"
                      name="confirmPassword"
                      type={showConfirmPassword ? "text" : "password"}
                      placeholder="Confirmar contraseña"
                      value={formData.confirmPassword}
                      onChange={handleInputChange}
                      maxLength={10}
                      required
                      className={errors.confirmPassword ? "error" : ""}
                    />
                    <button
                      type="button"
                      className="password-toggle"
                      onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                      aria-label={showConfirmPassword ? "Ocultar contraseña" : "Mostrar contraseña"}
                    >
                      {showConfirmPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                    </button>
                  </div>
                  {errors.confirmPassword && <span className="field-error">{errors.confirmPassword}</span>}
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
                    Creando cuenta...
                  </>
                ) : (
                  <>
                    <UserPlus size={16} />
                    Crear Cuenta
                  </>
                )}
              </button>
            </form>
          ) : (
            <div className="auth-success animate-fade-in">
              <CheckCircle size={48} className="success-icon" />
              <h3>¡Cuenta Creada!</h3>
              <p>Tu cuenta ha sido creada exitosamente. Ya puedes iniciar sesión.</p>
            </div>
          )}

          <div className="auth-divider">
            <span>o</span>
          </div>

          <div className="auth-actions">
            <Link to="/auth/login" className="auth-button outline">
              <ArrowLeft size={16} />
              {isSuccess ? "Ir al inicio de sesión" : "Ya tengo cuenta"}
            </Link>
            {!isSuccess && (
              <Link to="/recovery" className="auth-button secondary">
                <KeyRound size={16} />
                ¿Olvidaste tu contraseña?
              </Link>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
