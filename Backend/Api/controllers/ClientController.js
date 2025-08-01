const clientService = require("../services/ClientService.js")
const { logErrorToDB } = require('../services/errorLog');

async function getAll(req, res) {
    try {
        const clients = await clientService.getAllClients();
        res.json(clients);
    }
    catch (error) {
        await logErrorToDB('ClientController', 'getAll', error.message, error.stack);
        res.status(500).json({ message: "Error al obtener clientes", error });
    }
}
async function reporte(req, res) {
    try {
        const clients = await clientService.reporte();
        res.json(clients);
    }
    catch (error) {
        await logErrorToDB('ClientController', 'reporte', error.message, error.stack);
        res.status(500).json({ message: "Error al obtener clientes", error });
    }
}
async function correos(req, res) {
    try {
        const clients = await clientService.correos();
        res.json(clients);
    }
    catch (error) {
        await logErrorToDB('ClientController', 'correos', error.message, error.stack);
        res.status(500).json({ message: "Error al obtener clientes", error });
    }
}

async function getById(req, res) {
    try {
        const clientId = req.params.id;
        const client = await clientService.getClientById(clientId);
        res.json(client);
    }
    catch (error) {
        await logErrorToDB('ClientController', 'getById', error.message, error.stack);
        res.status(500).json({ message: "Error al obtener cliente", error });
    }
}
async function create(req, res) {
    try {
        const client = req.body;
        const newClient = await clientService.createClient(client);
        if (newClient.error || newClient.ERROR || newClient.Error) {
            await logErrorToDB('ClientController', 'create', newClient.error || newClient.ERROR || newClient.Error, "");
            return res.status(400).json({ error: newClient.error || newClient.ERROR || newClient.Error });
        }
        res.status(201).json({ message: "Cliente creado con éxito", newClient });
    }
    catch (error) {
        res.status(500).json({ error: "Error al crear cliente", error });
        await logErrorToDB('ClientController', 'create', error.message, error.stack);
    }
}
async function update(req, res) {
    try {
        const client = req.body;
        const updatedClient = await clientService.updateClient(client);
        res.json(updatedClient);
    }
    catch (error) {
        res.status(500).json({ error: "Error al actualizar cliente", error });
        await logErrorToDB('ClientController', 'update', error.message, error.stack);
    }
}
async function changePassword(req, res) {
    try {
        const { userId, newPassword } = req.body;
        const updatedClient = await clientService.changePassword(userId, newPassword);
        res.json(updatedClient);
    }
    catch (error) {
        res.status(500).json({ message: "Error al cambiar contraseña", error });
        await logErrorToDB('ClientController', 'changePassword', error.message, error.stack);
    }
}
async function recoverPassword(req, res) {
    try {
        const { email } = req.body;
        const updatedClient = await clientService.recoverPassword(email);
        res.json(updatedClient);
    }
    catch (error) {
        res.status(500).json({ message: "Error al recuperar contraseña", error });
        await logErrorToDB('ClientController', 'recoverPassword', error.message, error.stack);
    }
}
async function enable(req, res) {
    try {
        const clientId = req.params.id;
        const updatedClient = await clientService.enableClient(clientId);
        if (!updatedClient) {
            await logErrorToDB('ClientController', 'enable', updatedClient.error || updatedClient.ERROR || updatedClient.Error||"No se pudo habilitar el cliente", "");
            return res.status(404).json({ enable: false, error: "No se pudo habilitar el cliente" });
        }
        return res.json({ enable: true, message: "Cliente habilitado exitosamente" });
    }
    catch (error) {
        await logErrorToDB('ClientController', 'enable', error.message, error.stack);
        res.status(500).json({ error: "Error al habilitar cliente", error });
    }

}
async function disable(req, res) {
    try {
        const clientId = req.params.id;
        const updatedClient = await clientService.disableClient(clientId);
        if (!updatedClient) {
            await logErrorToDB('ClientController', 'disable', updatedClient.error || updatedClient.ERROR || updatedClient.Error||"No se pudo deshabilitar el cliente", "");
            return res.status(404).json({ disable: false, error: "No se pudo deshabilitar el cliente" });
        }
        return res.json({ disable: true, message: "Cliente deshabilitado exitosamente" });
    }
    catch (error) {
        res.status(500).json({ error: "Error al deshabilitar cliente", error });
    }

}
async function updatePicture(req, res) {
    try {
        const client = req.body;
        const updatedClient = await clientService.updatePicture(client);
        res.json(updatedClient);
    }
    catch (error) {
        res.status(500).json({ error: "Error al actualizar cliente", error });
        await logErrorToDB('ClientController', 'updatePicture', error.message, error.stack);
    }
}
module.exports = {
    getAll,
    create,
    update,
    getById,
    changePassword,
    recoverPassword,
    enable,
    disable,
    updatePicture,
    reporte,
    correos
};
