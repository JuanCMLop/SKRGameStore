<%@page import="beans.Payment"%>
<%@page import="common.*"%>

<jsp:include page="layout_top.jsp" />
<jsp:include page="layout_header.jsp" />
<%
    String errmsg = "";
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_CART);

    Payment payment = new Payment(helper.username(), "Jr. Enrique Cali 167, Comas", "1301122033287499");
    if ("GET".equalsIgnoreCase(request.getMethod())) {

    } else {
        String address = request.getParameter("address");
        String creditcard = request.getParameter("creditcard");
        payment.setAddress(address);
        payment.setCreditCard(creditcard);
        if (address == null || address.isEmpty()) {
            errmsg = "La dirección no puede estar vacía!";
        } else if (creditcard == null || creditcard.length() != 16) {
            errmsg = "La tarjeta de crédito no puede estar vacía y debe tener 16 números!";
        }

        if (errmsg.isEmpty()) {
            request.setAttribute("address", address);
            request.setAttribute("creditcard", creditcard);
            RequestDispatcher dispatcher = request.getServletContext().getRequestDispatcher("/orderplace.jsp");
            dispatcher.forward(request, response);
        }
    }
    pageContext.setAttribute("errmsg", errmsg);
    pageContext.setAttribute("payment", payment);
%>
<jsp:include page="layout_menu.jsp" />
<section id="content">
    <div class="post">
        <h3>Proporcione su direccion y tarjeta de credito</h3>
        <h3 style='color:red'>${errmsg}</h3>
        <form action="checkout.jsp" method="Post">
            <table style='width:55%'>
                <tr><td>Nombres:</td><td><input type='text' name='username' value='${payment.name}' required disabled/></td></tr>
                <tr><td>Dirección:</td><td><input type='text' name='address' value='${payment.address}' required /></td></tr>
                <tr><td>N° Tarjeta de Crédito</td><td><input type='text' name='creditcard' value='${payment.creditCard}' required /></td></tr>
                <tr><td><a href='mycart.jsp' class='button2'>Volver al Carrito</a></td><td><input name="create" value="Realizar pedido" type="submit" class="formbutton" /></td></tr>
            </table>	  
        </form>
    </div>
</section>
<jsp:include page="layout_sidebar.jsp" />
<jsp:include page="layout_footer.jsp" />