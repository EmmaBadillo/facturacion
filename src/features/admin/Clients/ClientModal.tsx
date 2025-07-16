"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { X, Save, Lock, Eye } from "lucide-react"
import type { Client } from "../../../types/User"
import "./ClientModal.css"

interface ClientModalProps {
  client: Client | null
  isOpen: boolean
  onClose: () => void
  onSave: (client: any) => void
  isCreating: boolean
  loading: boolean
}

export function ClientModal({ client, isOpen, onClose, onSave, isCreating, loading }: ClientModalProps) {
  const [formData, setFormData] = useState({
    firstName: "",
    lastName: "",
    email: "",
    cedula: "",
    address: "",
    phone: "",
    password: "",
    isBlocked: false,
  })
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [showPassword, setShowPassword] = useState(false)

  useEffect(() => {
    if (client) {
      setFormData({
        firstName: client.primerNombre ?? "",
        lastName: client.primerApellido ?? "",
        email: client.email ?? "",
        cedula: client.cedula ?? "",
        address: client.direccion ?? "",
        phone: client.telefono ?? "",
        password: "",
        isBlocked: client.isBlocked ?? false,
      })
    } else {
      setFormData({
        firstName: "",
        lastName: "",
        email: "",
        cedula: "",
        address: "",
        phone: "",
        password: "",
        isBlocked: false,
      })
    }
    setErrors({})
  }, [client, isOpen])

  const validateForm = () => {
    const newErrors: Record<string, string> = {}

    // First Name validation: required, no numbers
    if (!formData.firstName.trim()) {
      newErrors.firstName = "El nombre es requerido"
    } else if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/.test(formData.firstName)) {
      newErrors.firstName = "El nombre no debe contener números ni caracteres especiales"
    }

    // Last Name validation: required, no numbers
    if (!formData.lastName.trim()) {
      newErrors.lastName = "El apellido es requerido"
    } else if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/.test(formData.lastName)) {
      newErrors.lastName = "El apellido no debe contener números ni caracteres especiales"
    }

    // Email validation: required, valid format
    if (!formData.email.trim()) {
      newErrors.email = "El email es requerido"
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = "El email no es válido"
    }

    // Cedula validation: required, 10 digits, numeric, basic Ecuadorian validation
    if (!formData.cedula.trim()) {
      newErrors.cedula = "La cédula es requerida"
    } else if (!/^[0-9]{10}$/.test(formData.cedula)) {
      newErrors.cedula = "La cédula debe tener exactamente 10 dígitos numéricos"
    } else {
      // Basic Ecuadorian cedula validation (checksum)
      const cedula = formData.cedula
      const provincia = Number.parseInt(cedula.substring(0, 2), 10)
      if (provincia < 1 || provincia > 24) {
        newErrors.cedula = "Cédula inválida (provincia)"
      }
      const thirdDigit = Number.parseInt(cedula.charAt(2), 10)
      if (thirdDigit >= 6) {
        newErrors.cedula = "Cédula inválida (tercer dígito)"
      }
      const lastDigit = Number.parseInt(cedula.charAt(9), 10)
      let sum = 0
      for (let i = 0; i < 9; i++) {
        let digit = Number.parseInt(cedula.charAt(i), 10)
        if (i % 2 === 0) {
          digit *= 2
          if (digit > 9) digit -= 9
        }
        sum += digit
      }
      const calculatedCheckDigit = sum % 10 === 0 ? 0 : 10 - (sum % 10)
      if (calculatedCheckDigit !== lastDigit) {
        newErrors.cedula = "Cédula inválida (dígito verificador)"
      }
    }

    // Phone validation: required, starts with 09, 10 digits, numeric
    if (!formData.phone.trim()) {
      newErrors.phone = "El teléfono es requerido"
    } else if (!/^09[0-9]{8}$/.test(formData.phone)) {
      newErrors.phone = "El teléfono debe comenzar con '09' y tener 10 dígitos numéricos"
    }

    // Address validation: required
    if (!formData.address.trim()) {
      newErrors.address = "La dirección es requerida"
    }

    // Password validation: required for creation, min 6 chars, complexity
    if (isCreating) {
      if (!formData.password.trim()) {
        newErrors.password = "La contraseña es requerida"
      } else if (formData.password.length < 6) {
        newErrors.password = "La contraseña debe tener al menos 6 caracteres"
      } else if (!/(?=.*[a-z])/.test(formData.password)) {
        newErrors.password = "La contraseña debe contener al menos una letra minúscula"
      } else if (!/(?=.*[A-Z])/.test(formData.password)) {
        newErrors.password = "La contraseña debe contener al menos una letra mayúscula"
      } else if (!/(?=.*\d)/.test(formData.password)) {
        newErrors.password = "La contraseña debe contener al menos un número"
      } else if (!/(?=.*[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?])/.test(formData.password)) {
        newErrors.password = "La contraseña debe contener al menos un carácter especial"
      }
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!validateForm()) {
      return
    }
    const clientData = {
      ...formData,
      clientId: client?.clientId,
    }
    onSave(clientData)
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value, type } = e.target
    setFormData((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? (e.target as HTMLInputElement).checked : value,
    }))
    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: "" }))
    }
  }

  if (!isOpen) return null

  return (
    <div className="client-modal__overlay">
      <div className="client-modal__content" onClick={(e) => e.stopPropagation()}>
        <div className="client-modal__header">
          <h2 className="client-modal__title">{isCreating ? "Crear Cliente" : "Editar Cliente"}</h2>
          <button className="client-modal__close-btn" onClick={onClose} disabled={loading}>
            <X size={24} />
          </button>
        </div>
        <form onSubmit={handleSubmit} className="client-modal__form">
          <div className="client-modal__form-grid">
            <div className="client-modal__form-group">
              <label htmlFor="firstName" className="client-modal__label">
                Nombre *
              </label>
              <input
                type="text"
                id="firstName"
                name="firstName"
                value={formData.firstName}
                onChange={handleInputChange}
                className={`client-modal__input ${errors.firstName ? "error" : ""}`}
                disabled={loading}
                placeholder="Ej: Juan"
              />
              {errors.firstName && <span className="client-modal__error">{errors.firstName}</span>}
            </div>
            <div className="client-modal__form-group">
              <label htmlFor="lastName" className="client-modal__label">
                Apellido *
              </label>
              <input
                type="text"
                id="lastName"
                name="lastName"
                value={formData.lastName}
                onChange={handleInputChange}
                className={`client-modal__input ${errors.lastName ? "error" : ""}`}
                disabled={loading}
                placeholder="Ej: Pérez"
              />
              {errors.lastName && <span className="client-modal__error">{errors.lastName}</span>}
            </div>
            <div className="client-modal__form-group">
              <label htmlFor="email" className="client-modal__label">
                Email *
              </label>
              <input
                type="email"
                id="email"
                name="email"
                value={formData.email}
                onChange={handleInputChange}
                className={`client-modal__input ${errors.email ? "error" : ""}`}
                disabled={loading}
                placeholder="Ej: juan.perez@example.com"
              />
              {errors.email && <span className="client-modal__error">{errors.email}</span>}
            </div>
            <div className="client-modal__form-group">
              <label htmlFor="cedula" className="client-modal__label">
                Cédula *
              </label>
              <input
                type="text"
                id="cedula"
                name="cedula"
                value={formData.cedula}
                onChange={handleInputChange}
                maxLength={10}
                className={`client-modal__input ${errors.cedula ? "error" : ""}`}
                disabled={loading}
                placeholder="Ej: 1712345678"
              />
              {errors.cedula && <span className="client-modal__error">{errors.cedula}</span>}
            </div>
            <div className="client-modal__form-group">
              <label htmlFor="phone" className="client-modal__label">
                Teléfono *
              </label>
              <input
                type="tel"
                id="phone"
                name="phone"
                value={formData.phone}
                onChange={handleInputChange}
                maxLength={10}
                className={`client-modal__input ${errors.phone ? "error" : ""}`}
                disabled={loading}
                placeholder="Ej: 0991234567"
              />
              {errors.phone && <span className="client-modal__error">{errors.phone}</span>}
            </div>
            {isCreating && (
              <div className="client-modal__form-group">
                <label htmlFor="password" className="client-modal__label">
                  Contraseña *
                </label>
                <div style={{ position: "relative" }}>
                  <input
                    type={showPassword ? "text" : "password"}
                    id="password"
                    name="password"
                    value={formData.password}
                    onChange={handleInputChange}
                    className={`client-modal__input ${errors.password ? "error" : ""}`}
                    disabled={loading}
                    placeholder="Mín. 6 caracteres, mayús, minús, número, especial"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((prev) => !prev)}
                    className="show-password-button"
                    style={{
                      position: "absolute",
                      top: "50%",
                      right: "10px",
                      transform: "translateY(-50%)",
                      background: "none",
                      border: "none",
                      cursor: "pointer",
                      fontSize: "16px",
                      color: "var(--text-secondary)",
                    }}
                  >
                    {showPassword ? <Lock size={18} /> : <Eye size={18} />}
                  </button>
                </div>
                {errors.password && <span className="client-modal__error">{errors.password}</span>}
              </div>
            )}
          </div>
          <div className="client-modal__form-group">
            <label htmlFor="address" className="client-modal__label">
              Dirección *
            </label>
            <textarea
              id="address"
              name="address"
              value={formData.address}
              onChange={handleInputChange}
              className={`client-modal__textarea ${errors.address ? "error" : ""}`}
              rows={3}
              disabled={loading}
              placeholder="Ej: Calle Principal 123, Ciudad, País"
            />
            {errors.address && <span className="client-modal__error">{errors.address}</span>}
          </div>
          <div className="client-modal__actions">
            <button type="button" onClick={onClose} className="client-modal__cancel-btn" disabled={loading}>
              Cancelar
            </button>
            <button type="submit" className="client-modal__save-btn" disabled={loading}>
              {loading ? <div className="client-modal__button-spinner"></div> : <Save size={20} />}
              {isCreating ? "Crear" : "Guardar"}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
