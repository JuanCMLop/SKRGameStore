<%@page import="db.OrderDB"%>
<%@page import="java.util.List"%>
<%@page import="beans.Order"%>
<%@page import="common.*"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="layout_top.jsp" />
<jsp:include page="layout_header.jsp" />
<%
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_ALLORDERS);
    if (!helper.isLoggedin()) {
        session.setAttribute(Constants.SESSION_LOGIN_MSG, "Porfavor inciar sesi�n!");
        response.sendRedirect("account_login.jsp");
        return;
    }

    String usertype = helper.usertype();
    String errmsg = "";
    if (usertype == null || !usertype.equals(Constants.CONST_TYPE_SALESMAN_LOWER)) {
        errmsg = "No tienes autorizaci�n para gestionar el pedido!";
    }

    List<Order> list = OrderDB.getList();
    if (list == null || list.size() == 0) {
        errmsg = "A�n no hay pedido!";
    } else {
        String orderid = request.getParameter("orderid");
        String itemid = request.getParameter("itemid");
        String strtype = request.getParameter("type");
        String strQuantity = request.getParameter("quantity");
        if (orderid != null && itemid != null && strtype != null && strQuantity != null) {
            int type = 0;
            try {
                type = Integer.parseInt(strtype);
            } catch (NumberFormatException nfe) {

            }
            int quantity;
            try {
                quantity = Integer.parseInt(strQuantity);
            } catch (NumberFormatException nfe) {
                quantity = 1;
            }
            OrderDB.setItemQuantity(Integer.parseInt(orderid), Integer.parseInt(itemid), quantity);
        }
    }

    if ("GET".equalsIgnoreCase(request.getMethod())) {
        if (list != null) {
            for (Order ord : list) {
                session.removeAttribute("OrderItem" + ord.getId());
            }
        }
    }
    pageContext.setAttribute("errmsg", errmsg);
    pageContext.setAttribute("list", list);
%>
<jsp:include page="layout_menu.jsp" />
<section id='content'>
    <div class='cart'>
        <h3>Todos los Pedidos</h3>
        <c:choose>
            <c:when test="${not empty errmsg}">
                <h3 style='color:red'>${errmsg}</h3>
            </c:when>
            <c:otherwise>
                <div style='padding:5px'><a href='admin_orderadd.jsp' class='button'>Crear Nuevo Pedido</a></div>
                <table cellspacing='0'>
                    <tr><th>Pedido Id</th><th>Nom. Cliente</th><th>Fecha Entrega</th><th>Acci�n</th></tr>
                            <c:forEach var="order" items="${list}">
                        <tr>
                            <td><c:out value="${order.id}"/></td><td><c:out value="${order.userName}"/></td><td><c:out value="${order.formatDeliveryDate}"/></td>
                            <td>
                                <span style='padding-right:3px;'><a href='admin_orderedit.jsp?orderid=<c:out value="${order.id}"/>' class='button'>Editar</a></span>
                                <span><a href='admin_orderdel.jsp?orderid=<c:out value="${order.id}"/>' class='button' onclick = "return confirm('�Est�s seguro de eliminar este pedido?')">Eliminar</a></span>
                            </td>
                        </tr>
                    </c:forEach>               
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</section>    
<jsp:include page="layout_sidebar.jsp" />
<jsp:include page="layout_footer.jsp" />