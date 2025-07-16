"use client"

import { useState } from "react"
import type { Product } from "../../types/Product"
import { Loader2, ImageOff, Folder, AlertTriangle, CheckCircle } from "lucide-react"
import "./ProductCard.css"

interface ProductCardProps {
  product: Product
}

export function ProductCard({ product }: ProductCardProps) {
  const [imageLoaded, setImageLoaded] = useState(false)
  const [imageError, setImageError] = useState(false)

  const handleImageLoad = () => {
    setImageLoaded(true)
  }

  const handleImageError = () => {
    setImageError(true)
    setImageLoaded(true)
  }

  const getStockInfo = () => {
    if (product.stock === undefined) return null

    const stockCount = product.stock

    if (stockCount === 0) {
      return {
        icon: <AlertTriangle size={14} />,
        text: "Sin stock",
        className: "out-of-stock",
      }
    }

    if (stockCount <= 5) {
      return {
        icon: <AlertTriangle size={14} />,
        text: `Solo ${stockCount} disponibles`,
        className: "low-stock",
      }
    }

    return {
      icon: <CheckCircle size={14} />,
      text: `${stockCount} disponibles`,
      className: "in-stock",
    }
  }

  const stockInfo = getStockInfo()

  return (
    <article className="product-card">
      <div className="product-image-wrapper">
        {!imageLoaded && !imageError && (
          <div className="image-loading">
            <Loader2 className="loading-icon" />
            <span className="loading-text">Cargando imagen...</span>
          </div>
        )}

        {imageError ? (
          <div className="image-placeholder">
            <ImageOff size={40} />
            <span className="placeholder-text">Imagen no disponible</span>
          </div>
        ) : (
          <img
            src={product.image || "/placeholder.svg?height=240&width=320"}
            alt={product.name}
            className={`product-image ${imageLoaded ? "loaded" : ""}`}
            onLoad={handleImageLoad}
            onError={handleImageError}
            loading="lazy"
          />
        )}
      </div>

      <div className="product-details">
        <header className="product-header">
          <h3 className="product-name" title={product.name}>
            {product.name}
          </h3>
          {product.category && (
            <div className="product-category-tag">
              <Folder size={12} />
              <span>{product.category}</span>
            </div>
          )}
        </header>

        <p className="product-description" title={product.description}>
          {product.description}
        </p>

        <footer className="product-footer">
          <div className="price-section">
            <span className="price-currency">$</span>
            <span className="product-price">
              {product.price.toLocaleString("es-ES", {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2,
              })}
            </span>
          </div>

          {stockInfo && (
            <div className={`stock-status-info ${stockInfo.className}`}>
              {stockInfo.icon}
              <span>{stockInfo.text}</span>
            </div>
          )}
        </footer>
      </div>
    </article>
  )
}
