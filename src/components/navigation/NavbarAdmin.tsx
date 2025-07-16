"use client"

import { useState, useEffect } from "react"
import { Home, History, LogOut, Menu, X, Box, Users, LayoutDashboard } from "lucide-react"
import { useAuth } from "../../auth/AuthContext"
import "./Navbar.css"

export function NavbarAdmin() {
  const { user, logout } = useAuth()
  const [isOpen, setIsOpen] = useState(false)

  const toggleMenu = () => {
    setIsOpen(!isOpen)
  }

  const closeMenu = () => {
    setIsOpen(false)
  }

  useEffect(() => {
    if (isOpen) {
      document.body.classList.add("menu-open")
    } else {
      document.body.classList.remove("menu-open")
    }
    return () => {
      document.body.classList.remove("menu-open")
    }
  }, [isOpen])

  return (
    <>
      <nav className="app-navbar">
        <div className="navbar-container">
          {/* Brand/Logo */}
          <div className="navbar-brand">
            <LayoutDashboard size={24} className="brand-icon" />
            <span className="brand-text">Admin Portal</span>
          </div>

          {/* Desktop Navigation Links */}
          <div className="navbar-center">
            <ul className="nav-links-desktop">
              <li>
                <a href="/admin/home" className="nav-link">
                  <Home size={18} />
                  <span>Home</span>
                </a>
              </li>
              <li>
                <a href="/admin/history" className="nav-link">
                  <History size={18} />
                  <span>Historial</span>
                </a>
              </li>
              <li>
                <a href="/admin/products" className="nav-link">
                  <Box size={18} />
                  <span>Productos</span>
                </a>
              </li>
              <li>
                <a href="/admin/clients" className="nav-link">
                  <Users size={18} />
                  <span>Clientes</span>
                </a>
              </li>
            </ul>
          </div>

          {/* Right side - Desktop Logout + Mobile Menu Toggle */}
          <div className="navbar-right">
            <span className="user-greeting">Bienvenido, {user?.nombre || "Admin"}</span>
            <button className="logout-button-desktop" onClick={logout}>
              <LogOut size={18} />
              <span>Cerrar Sesión</span>
            </button>
            <button className="menu-toggle" onClick={toggleMenu} aria-label="Abrir menú">
              <Menu size={24} />
            </button>
          </div>
        </div>
      </nav>

      {/* Mobile Menu Sliding from Left */}
      <div className={`mobile-menu ${isOpen ? "mobile-menu-open" : ""}`}>
        <div className="mobile-menu-header">
          <span className="mobile-brand-text">Admin Portal</span>
          <button className="mobile-close-button" onClick={closeMenu} aria-label="Cerrar menú">
            <X size={24} />
          </button>
        </div>
        <ul className="mobile-nav-links">
          <li>
            <a href="/admin/home" className="mobile-nav-link" onClick={closeMenu}>
              <Home size={20} />
              <span>Home</span>
            </a>
          </li>
          <li>
            <a href="/admin/history" className="mobile-nav-link" onClick={closeMenu}>
              <History size={20} />
              <span>Historial</span>
            </a>
          </li>
          <li>
            <a href="/admin/products" className="mobile-nav-link" onClick={closeMenu}>
              <Box size={20} />
              <span>Productos</span>
            </a>
          </li>
          <li>
            <a href="/admin/clients" className="mobile-nav-link" onClick={closeMenu}>
              <Users size={20} />
              <span>Clientes</span>
            </a>
          </li>
          <li>
            <button
              className="mobile-logout-button"
              onClick={() => {
                closeMenu()
                logout()
              }}
            >
              <LogOut size={20} />
              <span>Cerrar Sesión</span>
            </button>
          </li>
        </ul>
      </div>

      {/* Overlay */}
      {isOpen && <div className={`navbar-overlay ${isOpen ? "show" : ""}`} onClick={closeMenu} aria-hidden="true" />}
    </>
  )
}
