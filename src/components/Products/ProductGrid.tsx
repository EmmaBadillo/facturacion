"use client"

import type { Product } from "../../types/Product"
import { ProductCard } from "./ProductCard"
import { Package, Search } from "lucide-react"
import "./ProductGrid.css"

interface ProductGridProps {
  products: Product[]
  loading: boolean
}

export function ProductGrid({ products, loading }: ProductGridProps) {
  if (loading) {
    return (
      <div className="product-grid-container">
        <div className="loading-header">
          <div className="loading-indicator">
            <div className="loading-spinner"></div>
            <span>Cargando productos...</span>
          </div>
        </div>
        <div className="product-grid loading">
          {Array.from({ length: 12 }).map((_, index) => (
            <div key={index} className="product-card-skeleton">
              <div className="skeleton-image">
                <div className="skeleton-shimmer"></div>
              </div>
              <div className="skeleton-content">
                <div className="skeleton-header">
                  <div className="skeleton-title">
                    <div className="skeleton-shimmer"></div>
                  </div>
                  <div className="skeleton-category">
                    <div className="skeleton-shimmer"></div>
                  </div>
                </div>
                <div className="skeleton-description">
                  <div className="skeleton-shimmer"></div>
                </div>
                <div className="skeleton-description short">
                  <div className="skeleton-shimmer"></div>
                </div>
                <div className="skeleton-footer">
                  <div className="skeleton-price">
                    <div className="skeleton-shimmer"></div>
                  </div>
                  <div className="skeleton-stock">
                    <div className="skeleton-shimmer"></div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    )
  }

  if (products.length === 0) {
    return (
      <div className="product-grid-container">
        <div className="no-products">
          <div className="no-products-content">
            <div className="no-products-icon">
              <Package size={64} />
              <Search size={28} className="search-overlay" />
            </div>
            <div className="no-products-text">
              <h3 className="no-products-title">No se encontraron productos</h3>
              <p className="no-products-message">No hay productos que coincidan con tu búsqueda actual.</p>
              <div className="no-products-suggestions">
                <h4>Sugerencias:</h4>
                <ul>
                  <li>Verifica la ortografía de tu búsqueda</li>
                  <li>Intenta con términos más generales</li>
                  <li>Explora otras categorías disponibles</li>
                  <li>Limpia los filtros aplicados</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="product-grid-container">
      <div className="products-header">
        <div className="products-count">
          <Package size={18} />
          <span>{products.length} productos encontrados</span>
        </div>
      </div>
      <div className="product-grid">
        {products.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>
    </div>
  )
}
