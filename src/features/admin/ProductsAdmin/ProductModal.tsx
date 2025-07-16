import type React from "react"
import { useState, useEffect } from "react"
import { X, Save } from "lucide-react"
import type { Product } from "../../../types/Product"
import "./ProductModal.css"

interface Category {
  CategoryId: number
  CategoryName: string
}

interface ProductModalProps {
  product: Product | null
  categories: Category[]
  isOpen: boolean
  onClose: () => void
  onSave: (product: any) => void
  isCreating: boolean
  loading: boolean
}

export function ProductModal({ product, categories, isOpen, onClose, onSave, isCreating, loading }: ProductModalProps) {
  const [formData, setFormData] = useState({
    name: "",
    price: "",
    description: "",
    image: "",
    stock: "",
    categoryId: "",
  })
  const [errors, setErrors] = useState<Record<string, string>>({})

  useEffect(() => {
    if (product) {
      const category = categories.find((cat) => cat.CategoryName === product.category)
      setFormData({
        name: product.name,
        price: product.price.toString(),
        description: product.description,
        image: product.image || "",
        stock: (product.stock || 0).toString(),
        categoryId: category ? category.CategoryId.toString() : "",
      })
    } else {
      setFormData({
        name: "",
        price: "",
        description: "",
        image: "",
        stock: "",
        categoryId: "",
      })
    }
    setErrors({})
  }, [product, categories, isOpen])

  const validateForm = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.name.trim()) {
      newErrors.name = "El nombre es requerido."
    } else if (formData.name.trim().length < 3) {
      newErrors.name = "El nombre debe tener al menos 3 caracteres."
    } else if (formData.name.trim().length > 100) {
      newErrors.name = "El nombre no puede exceder los 100 caracteres."
    }

    const priceValue = Number.parseFloat(formData.price)
    if (isNaN(priceValue) || formData.price.trim() === "") {
      newErrors.price = "El precio es requerido."
    } else if (priceValue <= 0) {
      newErrors.price = "El precio debe ser mayor a 0."
    } else if (formData.price.length > 10 || priceValue > 9999999.99) {
      newErrors.price = "El precio es demasiado alto o tiene formato incorrecto."
    } else if (!/^\d+(\.\d{1,2})?$/.test(formData.price)) {
      newErrors.price = "El precio debe tener hasta 2 decimales."
    }

    if (!formData.description.trim()) {
      newErrors.description = "La descripción es requerida."
    } else if (formData.description.trim().length < 10) {
      newErrors.description = "La descripción debe tener al menos 10 caracteres."
    } else if (formData.description.trim().length > 500) {
      newErrors.description = "La descripción no puede exceder los 500 caracteres."
    }

    const stockValue = Number.parseInt(formData.stock)
    if (isNaN(stockValue) || formData.stock.trim() === "") {
      newErrors.stock = "El stock es requerido."
    } else if (stockValue < 0) {
      newErrors.stock = "El stock no puede ser negativo."
    } else if (formData.stock.length > 8 || stockValue > 99999999) {
      newErrors.stock = "El stock es demasiado alto."
    }

    if (!formData.categoryId) {
      newErrors.categoryId = "La categoría es requerida."
    }

    if (formData.image.trim() !== "" && !/^https?:\/\/\S+\.\S+$/.test(formData.image)) {
      newErrors.image = "Formato de URL de imagen inválido."
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!validateForm()) {
      return
    }
    onSave(formData)
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }))
    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: "" }))
    }
  }

  if (!isOpen) return null

  return (
    <div className="product-modal__overlay" onClick={onClose}>
      <div className="product-modal__content" onClick={(e) => e.stopPropagation()}>
        <div className="product-modal__header">
          <h2 className="product-modal__title">{isCreating ? "Crear Producto" : "Editar Producto"}</h2>
          <button className="product-modal__close-btn" onClick={onClose} disabled={loading}>
            <X size={20} />
          </button>
        </div>
        <form onSubmit={handleSubmit} className="product-modal__form">
          <div className="product-modal__form-grid">
            <div className="product-modal__form-group">
              <label htmlFor="name" className="product-modal__label">
                Nombre *
              </label>
              <input
                type="text"
                id="name"
                name="name"
                value={formData.name}
                onChange={handleInputChange}
                maxLength={100}
                className={`product-modal__input ${errors.name ? "error" : ""}`}
                disabled={loading}
              />
              {errors.name && <span className="product-modal__error">{errors.name}</span>}
            </div>
            <div className="product-modal__form-group">
              <label htmlFor="price" className="product-modal__label">
                Precio *
              </label>
              <input
                type="number"
                id="price"
                name="price"
                value={formData.price}
                maxLength={10}
                onChange={handleInputChange}
                step="0.01"
                min="0"
                className={`product-modal__input ${errors.price ? "error" : ""}`}
                disabled={loading}
              />
              {errors.price && <span className="product-modal__error">{errors.price}</span>}
            </div>
            <div className="product-modal__form-group">
              <label htmlFor="stock" className="product-modal__label">
                Stock *
              </label>
              <input
                type="number"
                id="stock"
                name="stock"
                value={formData.stock}
                onChange={handleInputChange}
                maxLength={8}
                min="0"
                className={`product-modal__input ${errors.stock ? "error" : ""}`}
                disabled={loading}
              />
              {errors.stock && <span className="product-modal__error">{errors.stock}</span>}
            </div>
            <div className="product-modal__form-group">
              <label htmlFor="categoryId" className="product-modal__label">
                Categoría *
              </label>
              <select
                id="categoryId"
                name="categoryId"
                value={formData.categoryId}
                onChange={handleInputChange}
                className={`product-modal__select ${errors.categoryId ? "error" : ""}`}
                disabled={loading}
              >
                <option value="">Seleccionar categoría</option>
                {categories.map((category) => (
                  <option key={category.CategoryId} value={category.CategoryId.toString()}>
                    {category.CategoryName}
                  </option>
                ))}
              </select>
              {errors.categoryId && <span className="product-modal__error">{errors.categoryId}</span>}
            </div>
          </div>
          <div className="product-modal__form-group">
            <label htmlFor="description" className="product-modal__label">
              Descripción *
            </label>
            <textarea
              id="description"
              name="description"
              value={formData.description}
              onChange={handleInputChange}
              className={`product-modal__textarea ${errors.description ? "error" : ""}`}
              rows={3}
              disabled={loading}
            />
            {errors.description && <span className="product-modal__error">{errors.description}</span>}
          </div>
          <div className="product-modal__form-group">
            <label htmlFor="image" className="product-modal__label">
              URL de Imagen
            </label>
            <input
              type="url"
              id="image"
              name="image"
              value={formData.image}
              onChange={handleInputChange}
              className={`product-modal__input ${errors.image ? "error" : ""}`}
              placeholder="https://ejemplo.com/imagen.jpg"
              disabled={loading}
            />
            {errors.image && <span className="product-modal__error">{errors.image}</span>}
          </div>
          {formData.image && (
            <div className="product-modal__image-preview">
              <img
                src={formData.image || "/placeholder.svg"}
                alt="Vista previa"
                className="product-modal__preview-image"
                onError={(e) => {
                  const target = e.target as HTMLImageElement
                  target.style.display = "none"
                }}
              />
            </div>
          )}
          <div className="product-modal__actions">
            <button type="button" onClick={onClose} className="product-modal__cancel-btn" disabled={loading}>
              Cancelar
            </button>
            <button type="submit" className="product-modal__save-btn" disabled={loading}>
              {loading ? <div className="product-modal__button-spinner"></div> : <Save size={16} />}
              {isCreating ? "Crear" : "Guardar"}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
