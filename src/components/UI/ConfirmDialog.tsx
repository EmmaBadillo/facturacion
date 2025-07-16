"use client"
import { AlertTriangle, X, Info, CircleX } from "lucide-react"
import "./ConfirmDialog.css"

interface ConfirmDialogProps {
  isOpen: boolean
  title: string
  message: string
  confirmText?: string
  cancelText?: string
  onConfirm: () => void
  onCancel: () => void
  type?: "danger" | "warning" | "info"
}

export function ConfirmDialog({
  isOpen,
  title,
  message,
  confirmText = "Confirmar",
  cancelText = "Cancelar",
  onConfirm,
  onCancel,
  type = "warning",
}: ConfirmDialogProps) {
  if (!isOpen) return null

  const getIcon = () => {
    switch (type) {
      case "danger":
        return <CircleX size={24} />
      case "warning":
        return <AlertTriangle size={24} />
      case "info":
        return <Info size={24} />
      default:
        return <AlertTriangle size={24} />
    }
  }

  return (
    <div className={`confirm-overlay ${isOpen ? "is-open" : ""}`}>
      <div className={`confirm-dialog confirm-${type}`}>
        <div className="confirm-header">
          <div className="confirm-icon">{getIcon()}</div>
          <h3 className="confirm-title">{title}</h3>
          <button className="confirm-close" onClick={onCancel} aria-label="Cerrar diálogo">
            <X size={20} />
          </button>
        </div>
        <div className="confirm-content">
          <p className="confirm-message">{message}</p>
        </div>
        <div className="confirm-actions">
          <button className="confirm-btn confirm-cancel" onClick={onCancel}>
            {cancelText}
          </button>
          <button className={`confirm-btn confirm-${type}-action`} onClick={onConfirm}>
            {confirmText}
          </button>
        </div>
      </div>
    </div>
  )
}
