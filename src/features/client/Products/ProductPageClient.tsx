"use client"

import { useEffect, useState } from "react"
import { getProductsService } from "../../../api/services/ProductService"
import { adaptProduct } from "../../../adapters/ProductAdapter"
import type { Product } from "../../../types/Product"
import { getCategoriesService } from "../../../api/services/CategoryService"
import type { Category } from "../../../types/Categorie"
import { adaptCategorie } from "../../../adapters/CategorieAdapter"
import { SearchFilters } from "./SearchFilters"
import { ProductGrid } from "../../../components/Products/ProductGrid"
import { Pagination } from "../../../components/Pagination/Pagination"
import { Loader2, Package, TrendingUp } from "lucide-react"
import "./productPage.css"

export function ProductPageClient() {
  const [products, setProducts] = useState<Product[]>([])
  const [categories, setCategories] = useState<Category[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedCategory, setSelectedCategory] = useState("")
  const [currentPage, setCurrentPage] = useState(1)
  const [totalProducts, setTotalProducts] = useState(0)
  const [productsLoading, setProductsLoading] = useState(false)

  const pageSize = 50
  const totalPages = Math.ceil(totalProducts / pageSize)

  const fetchProducts = async (page = 1, filtro = "", categoryId = "") => {
    setProductsLoading(true)
    try {
      const result = await getProductsService({
        filtro,
        categoryId,
        page,
        pageSize,
      })
      setProducts(result.products?.map((product: any) => adaptProduct(product)) || [])
      setTotalProducts(result.total || 0)
    } catch (error) {
      console.error("Error fetching products:", error)
      setProducts([])
    } finally {
      setProductsLoading(false)
    }
  }

  const fetchCategories = async () => {
    try {
      const result = await getCategoriesService()
      const adaptedCategories = result.map((category: any) => adaptCategorie(category))
      setCategories(adaptedCategories)
    } catch (error) {
      console.error("Error fetching categories:", error)
    }
  }

  useEffect(() => {
    const loadInitialData = async () => {
      setLoading(true)
      await Promise.all([fetchCategories(), fetchProducts(1, searchTerm, selectedCategory)])
      setLoading(false)
    }
    loadInitialData()
  }, [])

  useEffect(() => {
    if (!loading) {
      setCurrentPage(1)
      fetchProducts(1, searchTerm, selectedCategory)
    }
  }, [searchTerm, selectedCategory])

  const handlePageChange = (page: number) => {
    setCurrentPage(page)
    fetchProducts(page, searchTerm, selectedCategory)
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  const handleSearch = (term: string) => {
    setSearchTerm(term)
  }

  const handleCategoryChange = (categoryId: string) => {
    setSelectedCategory(categoryId)
  }

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-content">
          <Loader2 className="loading-spinner" />
          <h3>Cargando productos...</h3>
          <p>Preparando el catálogo para ti</p>
        </div>
      </div>
    )
  }

  return (
    <div className="product-page">
      <div className="product-page-header">
        <div className="header-content">
          <div className="header-text">
            <h1 className="page-title">
              <Package size={28} />
              Catálogo de Productos
            </h1>
            <p className="page-subtitle">Descubre nuestra amplia selección de productos de calidad</p>
          </div>
          <div className="header-stats">
            <div className="stat-card">
              <TrendingUp size={20} />
              <div className="stat-info">
                <span className="stat-number">{categories.length}</span>
                <span className="stat-label">Categorías</span>
              </div>
            </div>
            <div className="stat-card">
              <Package size={20} />
              <div className="stat-info">
                <span className="stat-number">{totalProducts}</span>
                <span className="stat-label">Productos</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="filters-section">
        <SearchFilters
          categories={categories}
          onSearch={handleSearch}
          onCategoryChange={handleCategoryChange}
          searchTerm={searchTerm}
          selectedCategory={selectedCategory}
        />
      </div>

      <div className="products-section">
        <div className="products-summary">
          <div className="summary-content">
            <span className="products-count">
              {productsLoading ? (
                <>
                  <Loader2 size={16} className="inline-spinner" />
                  Buscando productos...
                </>
              ) : (
                <>
                  {totalProducts} producto{totalProducts !== 1 ? "s" : ""} encontrado
                  {totalProducts !== 1 ? "s" : ""}
                </>
              )}
            </span>
            {totalPages > 1 && (
              <span className="page-info">
                Página {currentPage} de {totalPages}
              </span>
            )}
          </div>
        </div>

        <div className="products-content">
          <ProductGrid products={products} loading={productsLoading} />
        </div>

        {totalPages > 1 && (
          <div className="pagination-section">
            <Pagination currentPage={currentPage} totalPages={totalPages} onPageChange={handlePageChange} />
          </div>
        )}
      </div>
    </div>
  )
}
