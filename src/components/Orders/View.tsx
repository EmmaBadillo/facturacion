import type { Order } from "../../types/Order"
import type { OrderDetail } from "../../types/OrderDetail"

export const generatePrintContent = (orderInfo: Order, details: OrderDetail[]) => {
  return `
          <!DOCTYPE html>
          <html>
            <head>
              <title>Factura ${orderInfo.orderId}</title>
              <style>
                body {
                  font-family: 'Arial', sans-serif;
                  margin: 0;
                  padding: 20px;
                  background-color: #f8f9fa;
                  color: #333;
                }
                .invoice-container {
                  max-width: 800px;
                  margin: 0 auto;
                  background: white;
                  padding: 40px;
                  border-radius: 8px;
                  box-shadow: 0 0 20px rgba(0,0,0,0.1);
                  border: 1px solid #e0e0e0; /* Borde sutil */
                }
                .header {
                  text-align: center;
                  margin-bottom: 40px;
                  border-bottom: 3px solid #1e40af; /* Usando primary color */
                  padding-bottom: 20px;
                }
                .company-name {
                  font-size: 28px;
                  font-weight: bold;
                  color: #1e40af; /* Usando primary color */
                  margin-bottom: 10px;
                }
                .invoice-title {
                  font-size: 24px;
                  color: #059669; /* Usando accent color */
                  margin-bottom: 10px;
                }
                .invoice-number {
                  font-size: 18px;
                  color: #64748b; /* Usando secondary color */
                }
                .customer-section {
                  margin-bottom: 30px;
                  padding: 20px;
                  background-color: #f1f5f9; /* Usando bg-muted */
                  border-radius: 8px;
                  border: 1px solid #e2e8f0; /* Usando border color */
                }
                .section-title {
                  font-size: 18px;
                  font-weight: bold;
                  color: #0f172a; /* Usando text-primary */
                  margin-bottom: 15px;
                  border-bottom: 2px solid #059669; /* Usando accent color */
                  padding-bottom: 5px;
                }
                .customer-info {
                  display: grid;
                  grid-template-columns: 1fr 1fr;
                  gap: 15px;
                }
                .info-item {
                  display: flex;
                  flex-direction: column;
                }
                .info-label {
                  font-weight: bold;
                  color: #64748b; /* Usando text-muted */
                  font-size: 12px;
                  text-transform: uppercase;
                  margin-bottom: 5px;
                }
                .info-value {
                  color: #0f172a; /* Usando text-primary */
                  font-size: 14px;
                }
                .products-section {
                  margin: 30px 0;
                }
                .products-table {
                  width: 100%;
                  border-collapse: collapse;
                  margin-top: 15px;
                  border: 1px solid #e2e8f0; /* Usando border color */
                  border-radius: 8px;
                  overflow: hidden;
                }
                .products-table th {
                  background-color: #1e40af; /* Usando primary color */
                  color: white;
                  padding: 12px;
                  text-align: left;
                  font-weight: bold;
                }
                .products-table td {
                  padding: 12px;
                  border-bottom: 1px solid #e2e8f0; /* Usando border color */
                }
                .products-table tr:nth-child(even) {
                  background-color: #f8fafc; /* Un color más claro para filas pares */
                }
                .product-image {
                  width: 50px;
                  height: 50px;
                  object-fit: cover;
                  border-radius: 4px;
                  border: 1px solid #e2e8f0;
                }
                .product-name {
                  font-weight: 600;
                  color: #0f172a; /* Usando text-primary */
                }
                .price {
                  font-weight: 600;
                  color: #059669; /* Usando accent color */
                  text-align: end;
                }
                 table .price-th {
                  text-align: end;
                }
                .financial-section {
                  margin-top: 40px;
                  padding: 20px;
                  background-color: #f1f5f9; /* Usando bg-muted */
                  border-radius: 8px;
                  border: 1px solid #e2e8f0; /* Usando border color */
                }
                .financial-row {
                  display: flex;
                  justify-content: space-between;
                  margin-bottom: 10px;
                  padding: 8px 0;
                }
                .financial-label {
                  font-weight: 500;
                  color: #64748b; /* Usando text-muted */
                }
                .financial-value {
                  font-weight: 600;
                  color: #0f172a; /* Usando text-primary */
                }
                .total-row {
                  border-top: 2px solid #059669; /* Usando accent color */
                  margin-top: 15px;
                  padding-top: 15px;
                  font-size: 18px;
                  font-weight: bold;
                }
                .total-label {
                  color: #0f172a; /* Usando text-primary */
                }
                  .quantity{
                  text-align: center;
                  }
                .total-value {
                  color: #059669; /* Usando accent color */
                }
                .footer {
                  margin-top: 40px;
                  text-align: center;
                  color: #64748b; /* Usando text-muted */
                  font-size: 12px;
                  border-top: 1px solid #e2e8f0; /* Usando border color */
                  padding-top: 20px;
                }
                @media print {
                  body { background-color: white; }
                  .invoice-container { box-shadow: none; border: none; }
                }
              </style>
            </head>
            <body>
              <div class="invoice-container">
                <div class="header">
                  <div class="invoice-title">FACTURA</div>
                  <div class="invoice-number">Orden #${orderInfo.orderId}</div>
                </div>
                <div class="customer-section">
                  <div class="section-title">Información del Cliente</div>
                  <div class="customer-info">
                    <div class="info-item">
                      <div class="info-label">Nombre</div>
                      <div class="info-value">${orderInfo.customerName}</div>
                    </div>
                    <div class="info-item">
                      <div class="info-label">Email</div>
                      <div class="info-value">${orderInfo.customerEmail}</div>
                    </div>
                    <div class="info-item">
                      <div class="info-label">Teléfono</div>
                      <div class="info-value">${orderInfo.customerPhone}</div>
                    </div>
                    <div class="info-item">
                      <div class="info-label">Fecha</div>
                      <div class="info-value">${new Date(orderInfo.orderDate).toLocaleDateString("es-ES", {
    year: "numeric",
    month: "long",
    day: "numeric",
  })}</div>
                    </div>
                  </div>
                  <div style="margin-top: 15px;">
                    <div class="info-label">Dirección de Entrega</div>
                    <div class="info-value">${orderInfo.customerAddress}</div>
                  </div>
                </div>
                <div class="products-section">
                  <div class="section-title">Productos</div>
                  <table class="products-table">
                    <thead>
                      <tr>
                        <th>Código</th>
                        <th>Producto</th>
                        <th>Cantidad</th>
                        <th class="price-th">Precio Unit.</th>
                        <th class="price-th">Subtotal</th>
                      </tr>
                    </thead>
                    <tbody>
                      ${details
      .map(
        (item) => `
                          <tr>
                            <td># ${item.ProductId}</td>
                            <td class="product-name">${item.Name}</td>
                            <td class="quantity">${item.Quantity}</td>
                            <td class="price">$${item.UnitPrice.toFixed(2)}</td>
                            <td class="price">$${item.SubTotal.toFixed(2)}</td>
                          </tr>
                        `,
      )
      .join("")}
                    </tbody>
                  </table>
                </div>
                <div class="financial-section">
                  <div class="section-title">Resumen Financiero</div>
                  <div class="financial-row">
                    <span class="financial-label">Subtotal:</span>
                    <span class="financial-value">$${orderInfo.orderSubtotal?.toFixed(2) || "0.00"}</span>
                  </div>
                  <div class="financial-row">
                    <span class="financial-label">Impuestos:</span>
                    <span class="financial-value">$${orderInfo.orderTax?.toFixed(2) || "0.00"}</span>
                  </div>
                  <div class="financial-row total-row">
                    <span class="total-label">TOTAL:</span>
                    <span class="total-value">$${orderInfo.orderTotal?.toFixed(2) || "0.00"}</span>
                  </div>
                </div>
                <div class="footer">
                  <p>Gracias por su compra</p>
                  <p>Factura generada el ${new Date().toLocaleDateString("es-ES")}</p>
                </div>
              </div>
            </body>
          </html>
        `
}
