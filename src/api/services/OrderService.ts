import { ORDER_ENDPOINTS } from "../endpoints/Orders";

export async function getOrdersService(clientID?: number) {
    const res = await fetch(ORDER_ENDPOINTS.Orders + (clientID ? `?clientId=${clientID}` : ''), {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
    });
    if (!res.ok) {
        throw new Error('Failed to fetch clients');
    }
    return await res.json();
}
export async function createOrderService(order: any) {
    const res = await fetch(ORDER_ENDPOINTS.Orders, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(order),
    });
    if (!res.ok) {
        throw new Error('Failed to create order');
    }
    return await res.json();
}
export async function getNextOrderService() {
    const res = await fetch(ORDER_ENDPOINTS.NextOrder , {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
    });
    if (!res.ok) {
        throw new Error('Failed to fetch clients');
    }
    return await res.json();
}
export async function addDetailService(orderDetail: any, orderId: number) {
    try {
        for (const detail of orderDetail) {
            const res = await fetch(ORDER_ENDPOINTS.AddDetail, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    orderId: orderId,
                    productId: detail.productId,
                    quantity: detail.quantity,
                }),
            });

            if (!res.ok) {
                const errorData = await res.json();
                return errorData;
            }
        }

        return true;
    } catch (error) {
        return false; // Error inesperado
    }
}
export async function getDetailService(orderId: number) {
    console.log("Fetching order details for orderId:", ORDER_ENDPOINTS.Orders + `/${orderId}`);
    const res = await fetch(ORDER_ENDPOINTS.Orders + `/${orderId}`, {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
    });
    if (!res.ok) {
        throw new Error('Failed to fetch order details');
    }
    return await res.json();
}