import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import { LoginPage } from '../features/login/LoginPage';
import { AdminDashboard } from '../features/admin/AdminDashboard';
import { ClientDashboard } from '../features/client/ClientDashboard';

import { Recovery } from '../features/login/Recovery';
import { Register } from '../features/login/Register';

import HomeAdmin from '../features/admin/HomeAdmin/HomeAdmin';
import { HomeClient } from '../features/client/Home/HomeClient';
import { HistoryClient } from '../features/client/History/HistoryClient';
import { ProductPageClient } from '../features/client/Products/ProductPageClient';
import HistoryAdmin from '../features/admin/HistoryAdmin/HistoryAdmin';

import { ProductsAdmin } from '../features/admin/ProductsAdmin/ProductsAdmin';
import { ClientAdmin } from '../features/admin/Clients/ClientAdmin';

function PrivateRoute({ children, allowedRoles }: { children: React.ReactNode; allowedRoles: string[] }) {
  const { user, loading } = useAuth();
  if (loading) return <div>Cargando...</div>;

  if (!user) return <Navigate to="/login" replace />;

  if (!allowedRoles.some(role => role === user.rol)) return <Navigate to="/" replace />;

  return <>{children}</>;
}
export default function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<Register />} />
        <Route path="/recovery" element={<Recovery />} />

        <Route
          path="/admin/*" element={<PrivateRoute allowedRoles={['Admin']}>
            <AdminDashboard />
          </PrivateRoute>
          }>
          <Route index element={<HomeAdmin />} />
          <Route path='home' element={<HomeAdmin />} />
          <Route path='history' element={<HistoryAdmin />} />
          <Route path='products' element={<ProductsAdmin />} />
          <Route path='clients' element={<ClientAdmin />} />

        </Route>

        <Route
          path="/client/*"
          element={
            <PrivateRoute allowedRoles={['Client']}>
              <ClientDashboard />
            </PrivateRoute>
          }
        >
          <Route index element={<HomeClient />} />
          <Route path='home' element={<HomeClient />} />
          <Route path='history' element={<HistoryClient />} />
          <Route path='products' element={<ProductPageClient />} />
        </Route>
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
