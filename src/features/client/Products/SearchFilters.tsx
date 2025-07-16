"use client"

import type React from "react"
import { useState } from "react"
import type { Category } from "../../../types/Categorie"
import { Search, Folder, X, ChevronDown, Filter } from "lucide-react"
import "./SearchFilters.css"

interface SearchFiltersProps {
  categories: Category[]
  onSearch: (term: string) => void
  onCategoryChange: (categoryId: string) => void
  searchTerm: string
  selectedCategory: string
}

export function SearchFilters({
  categories,
  onSearch,
  onCategoryChange,
  searchTerm,
  selectedCategory,
}: SearchFiltersProps) {
  const [localSearchTerm, setLocalSearchTerm] = useState(searchTerm)

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    onSearch(localSearchTerm)
  }

  const handleClearFilters = () => {
    setLocalSearchTerm("")
    onSearch("")
    onCategoryChange("")
  }

  const hasActiveFilters = searchTerm || selectedCategory
  const selectedCategoryName = categories.find((c) => c.id === Number(selectedCategory))?.name

  return (
    <div className="search-filters">
      <div className="filters-container">
        <div className="filters-header">
          <div className="filters-title">
            <Filter size={18} />
            <h3>Filtros de búsqueda</h3>
          </div>
          {hasActiveFilters && (
            <button onClick={handleClearFilters} className="clear-all-btn">
              <X size={16} />
              Limpiar todo
            </button>
          )}
        </div>

        <div className="filters-content">
          <form onSubmit={handleSearchSubmit} className="search-form">
            <div className="form-group">
              <label className="form-label">
                <Search size={16} />
                Buscar productos
              </label>
              <div className="search-input-container">
                <input
                  type="text"
                  placeholder="Nombre, descripción, código..."
                  value={localSearchTerm}
                  onChange={(e) => setLocalSearchTerm(e.target.value)}
                  className="search-input"
                />
                {localSearchTerm && (
                  <button type="button" onClick={() => setLocalSearchTerm("")} className="clear-input-btn">
                    <X size={16} />
                  </button>
                )}
              </div>
            </div>
            <button type="submit" className="search-submit-btn">
              <Search size={16} />
              Buscar
            </button>
          </form>

          <div className="category-filter">
            <div className="form-group">
              <label htmlFor="category-select" className="form-label">
                <Folder size={16} />
                Categoría
              </label>
              <div className="select-container">
                <select
                  id="category-select"
                  value={selectedCategory}
                  onChange={(e) => onCategoryChange(e.target.value)}
                  className="category-select"
                >
                  <option value="">Todas las categorías</option>
                  {categories.map((category) => (
                    <option key={category.id} value={category.id}>
                      {category.name}
                    </option>
                  ))}
                </select>
                <ChevronDown className="select-arrow" size={16} />
              </div>
            </div>
          </div>
        </div>

        {hasActiveFilters && (
          <div className="active-filters">
            <div className="active-filters-header">
              <span className="active-filters-label">Filtros activos:</span>
            </div>
            <div className="filter-tags">
              {searchTerm && (
                <div className="filter-tag">
                  <Search size={12} />
                  <span>"{searchTerm}"</span>
                  <button onClick={() => onSearch("")} className="remove-filter">
                    <X size={12} />
                  </button>
                </div>
              )}
              {selectedCategory && (
                <div className="filter-tag">
                  <Folder size={12} />
                  <span>{selectedCategoryName}</span>
                  <button onClick={() => onCategoryChange("")} className="remove-filter">
                    <X size={12} />
                  </button>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
