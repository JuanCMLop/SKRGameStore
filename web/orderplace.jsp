<%@page import="db.OrderDB"%>
<%@page import="common.*"%>
<%@page import="dao.*"%>
<%@page import="beans.*"%>
<%@page import="java.util.*"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="layout_top.jsp" />
<jsp:include page="layout_header.jsp" />
<%
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_CART);
    if(!helper.isLoggedin()){
        session.setAttribute(Constants.SESSION_LOGIN_MSG, "Porfavor iniciar sesi�n!");
        response.sendRedirect("account_login.jsp");
        return;
    }
    
    String username = helper.username();
    String address = request.getParameter("address");
    String creditcard = request.getParameter("creditcard");
    
    String errmsg = "";    
    if (address == null || address.isEmpty() || creditcard == null || creditcard.isEmpty()) {
        errmsg = "�Par�metro no v�lido! Regrese al carrito para procesar nuevamente!";
    }
    
    ShoppingCart cart = null;
    List<CartItem> list = null;
    String orderid = "";
    String confirmation = "";
    Calendar c = null;
    
    if (errmsg.isEmpty()) {
        synchronized(session) {
            cart = (ShoppingCart)session.getAttribute(Constants.SESSION_CART);
            if (cart == null) {
                errmsg = "No hay art�culos en el carrito de compras, no se puede realizar el pedido!";
            } else {
                list = cart.getItems();
                if (list == null || list.size() == 0) { 
                    errmsg = "No hay art�culos en el carrito de compras, no se puede realizar el pedido!";
                }                
            }
        }        

        orderid = helper.generateUniqueId();
        confirmation = username + orderid.substring(orderid.length()-4) + creditcard.substring(creditcard.length() - 4);
        
        if (errmsg.isEmpty()) {
            Date now = new Date();
            c = Calendar.getInstance();
            c.setTime(now);
            c.add(Calendar.DATE, 14); // 2 weeks
             //create order
            Order order = new Order(0, helper.username(), address, creditcard, confirmation, c.getTime());
            for (CartItem ob: list) {
                OrderItem item = new OrderItem(0, 0, ob.getItemId(), ob.getItemName(), ob.getItem().getType(), ob.getItem().getPrice(), ob.getItem().getImage(), ob.getItem().getMaker(), ob.getItem().getDiscount(), 1);
                item.setQuantity(ob.getQuantity());
                order.addItem(item);
            }

            // create 
            int generatedKey = OrderDB.insert(order);
            order.setId(generatedKey);
            // remove cart from session
            session.removeAttribute(Constants.SESSION_CART);
            pageContext.setAttribute("order", order);
            pageContext.setAttribute("list", list);
        }
    }
    pageContext.setAttribute("errmsg", errmsg);
%>
<jsp:include page="layout_menu.jsp" />
<section id='content'>
    <div class='cart'>
        <h3>Pedido Confirmaci�n</h3>
        <c:choose>
            <c:when test="${not empty errmsg}">
                <h3 style='color:red'>${errmsg}</h3>    
            </c:when>
            <c:otherwise>
                <c:set var="total" value="0" scope="page" />
                <c:set var="counter" value="0" scope="page" />
                <table class="order_table">
                    <tr><td width="30%"><h5><i>Pedido Id: </i></h5></td><td width="70%">${order.id}</td></tr>
                    <tr><td><h5><i>Nom. Cliente: </i></h5></td><td>${order.userName}</td></tr>
                    <tr><td><h5><i>Direcci�n: </i></h5></td><td>${order.address}</td></tr>
                    <tr><td><h5><i>N� Confirmaci�n: </i></h5></td><td>${order.confirmationNumber}</td></tr>    
                    <tr><td><h5><i>Fecha de entrega: </i></h5></td><td>${order.formatDeliveryDate}</td><td></td></tr>
                </table>
                <table cellspacing='0'>
                    <tr><th>No.</th><th>Nom. Producto</th><th>Precio</th><th>Cant</th><th>SubTotal</th></tr>                
                <c:forEach var="cartitem" items="${list}">
                    <tr>
                        <td><c:out value="${counter + 1}"/></td>
                        <td><c:out value="${cartitem.itemName}"/></td>
                        <td><fmt:setLocale value="en_US"/><fmt:formatNumber value="${cartitem.unitPrice}" type="currency"/></td>
                        <td><c:out value="${cartitem.quantity}"/></td>                                 
                        <td><fmt:setLocale value="en_US"/><fmt:formatNumber value="${cartitem.totalCost}" type="currency"/></td>
                    </tr>
                    <c:set var="total" value="${total + cartitem.totalCost}" scope="page"/>
                    <c:set var="counter" value="${counter + 1}" scope="page"/>
                </c:forEach>
                <tr class='total'><td></td><td></td><td></td><td>Total</td><td><fmt:setLocale value="en_US"/><fmt:formatNumber value="${total}" type="currency"/></td></tr>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</section>
<jsp:include page="layout_sidebar.jsp" />
<jsp:include page="layout_footer.jsp" />