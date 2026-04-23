export type InvoiceItem = {
	id: number;
	description: string;
	quantity: number;
	unitPrice: number;
};

export type InvoiceFormData = {
	invoiceNumber: string;
	issueDate: string;
	dueDate: string;
	currency: string;
	notes: string;
	fromName: string;
	fromEmail: string;
	fromPhone: string;
	fromAddress: string;
	clientName: string;
	clientEmail: string;
	clientPhone: string;
	clientAddress: string;
};
