<%@page import="db.OrderDB"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="beans.*"%>
<%@page import="dao.UserDao"%>
<%@page import="java.util.ArrayList"%>
<%@page import="beans.SelectorOption"%>
<%@page import="java.util.List"%>
<%@page import="common.*"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="layout_top.jsp" />
<jsp:include page="layout_header.jsp" />
<%
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_ALLORDERS);
    if (!helper.isLoggedin()) {
        session.setAttribute(Constants.SESSION_LOGIN_MSG, "Porfavor iniciar sesi�n!");
        response.sendRedirect("account_login.jsp");
        return;
    }

    String usertype = helper.usertype();
    String errmsg = "";
    if (usertype == null || !usertype.equals(Constants.CONST_TYPE_SALESMAN_LOWER)) {
        errmsg = "No tienes autorizaci�n para gestionar pedidos!";
    }

    Order order = null;
    String username = request.getParameter("username");
    String address = request.getParameter("address");
    String creditcard = request.getParameter("creditcard");
    String actiontype = request.getParameter("actiontype");

    order = (Order) session.getAttribute(Constants.SESSION_ORDERITEM);

    if ("GET".equalsIgnoreCase(request.getMethod())) {
        if (order == null) {
            order = new Order();
            order.setUserName(username);
            order.setAddress(address);
            order.setCreditCard(creditcard);
            session.setAttribute(Constants.SESSION_ORDERITEM, order);
        }
    } else {
        if (actiontype != null && actiontype.equals("save")) {
            order.setUserName(username);
            order.setAddress(address);
            order.setCreditCard(creditcard);
            if (address == null || address.isEmpty()) {
                errmsg = "La direcci�n no puede estar vac�a!";
            } else if (creditcard == null || creditcard.length() != 16) {
                errmsg = "La tarjeta de cr�dito no puede estar vac�a y debe tener 16 n�meros!";
            } else {
                if (order != null) {
                    if (order.getItems().size() == 0) {
                        errmsg = "El pedido no contiene nada. Debes elegir al menos un producto!";
                    } else {
                        String uniqueid = helper.generateUniqueId();
                        String confirmation = username + uniqueid.substring(uniqueid.length() - 4) + creditcard.substring(creditcard.length() - 4);
                        Date now = new Date();
                        Calendar c = Calendar.getInstance();
                        c.setTime(now);
                        c.add(Calendar.DATE, 14); // 2 weeks
                        //set order
                        order.setUserName(username);
                        order.setAddress(address);
                        order.setCreditCard(creditcard);
                        order.setConfirmationNumber(confirmation);
                        order.setDeliveryDate(c.getTime());
                        // create
                        OrderDB.insert(order);
                        session.removeAttribute(Constants.SESSION_ORDERITEM);
                        response.sendRedirect("admin_orderlist.jsp");
                    }
                }
            }
        }
    }

    if (actiontype != null && actiontype.equals("updatequantity")) {
        if (order != null) {
            String itemid = request.getParameter("itemid");
            int id = Integer.parseInt(itemid);
            if (itemid != null && !itemid.isEmpty()) {
                String strQuantity = request.getParameter("quantity");
                int quantity;
                if (strQuantity == null || strQuantity.isEmpty()) {
                    quantity = 0;
                } else {
                    try {
                        quantity = Integer.parseInt(strQuantity);
                    } catch (NumberFormatException nfe) {
                        quantity = 1;
                    }
                }
                order.setItemQuantity(id, quantity);
            }
        }
    }

    UserDao dao = UserDao.createInstance();
    List<User> userlist = dao.getUserList();
    List<SelectorOption> list = new ArrayList<SelectorOption>();
    for (User user : userlist) {
        list.add(new SelectorOption(user.getName(), user.getName()));
    }

    pageContext.setAttribute("errmsg", errmsg);
    pageContext.setAttribute("list", list);
    pageContext.setAttribute("order", order);
%>
<jsp:include page="layout_menu.jsp" />
<section id='content'>
    <div class='cart'>
        <h3>Crear Pedido</h3>   
        <h3 style='color:red'>${errmsg}</h3>
        <div class="order_box">
            <form action="admin_orderadd.jsp?actiontype=save" method="Post">
                <table class="order_table">               
                    <tr><td><h5><i>Nom. Cliente: </i></h5></td>
                        <td>
                            <select name='username' id='username' class='input'>
                                <c:forEach var="option" items="${list}">
                                    <c:choose>
                                        <c:when test="${option.key == order.userName}">
                                            <option value=${option.key} selected>${option.text}</option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value=${option.key}>${option.text}</option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </td>
                        <td><input name="save" class="formbutton" value="Realizar Pedido" type="submit" /></td>
                    </tr>
                    <tr><td><h5><i>Direcci�n: </i></h5></td><td><input type='text' name='address' id='address' value='${order.address}' required /></td><td></td></tr>
                    <tr><td><h5><i>N� Tarjeta de Cr�dito: </i></h5></td><td><input type='text' name='creditcard' id='creditcard' value='${order.creditCard}' required /></td><td></td></tr>
                    <tr><td><h5><i>N� de Confirmaci�n: </i></h5></td><td><c:out value="${order.confirmationNumber}"/></td><td></td></tr>
                    <tr><td><h5><i>Fecha de entrega: </i></h5></td><td><c:out value="${order.formatDeliveryDate}"/></td><td></td></tr>
                </table>
            </form>
            <table cellspacing='0'>
                <tr><th>No.</th><th>Nombre</th><th>Precio</th><th>Cant</th><th>SubTotal</th><th>Acci�n</th></tr>
                        <c:set var="total" value="0" scope="page" />
                        <c:set var="counter" value="0" scope="page" />
                        <c:forEach var="orderitem" items="${order.getItems()}">                                
                    <tr>
                        <td><c:out value="${counter + 1}"/></td>
                        <td><c:out value="${orderitem.productName}"/></td>
                        <td><fmt:setLocale value="en_US"/><fmt:formatNumber value="${orderitem.unitPrice}" type="currency"/></td>
                        <td>
                            <form action="admin_orderadd.jsp?actiontype=updatequantity" method="Post">
                                <input type="hidden" name="orderid" value="<c:out value="${order.id}"/>">
                                <input type="hidden" name="itemid" value="<c:out value="${orderitem.orderItemId}"/>">
                                <input type="text" name="quantity" size=3 value="<c:out value="${orderitem.quantity}"/>">
                                <input type="submit" class="formbutton2" value="Update">
                            </form>
                        </td>
                        <td><fmt:setLocale value="en_US"/><fmt:formatNumber value="${orderitem.totalCost}" type="currency"/></td>
                        <td>
                            <span><a href='admin_orderadd.jsp?actiontype=updatequantity&orderid=<c:out value="${order.id}"/>&itemid=<c:out value="${orderitem.orderItemId}"/>&quantity=0' class='button3' onclick = "return confirm('�Est�s seguro de eliminar este producto?')">Eliminar</a></span>
                        </td>
                    </tr>
                    <c:set var="total" value="${total + orderitem.getTotalCost()}" scope="page"/>
                    <c:set var="counter" value="${counter + 1}" scope="page"/>
                </c:forEach>
                <tr class='total'><td></td><td></td><td></td><td>Total</td><td><fmt:setLocale value="en_US"/><fmt:formatNumber value="${total}" type="currency"/></td><td></td></tr>
                <tr><td colspan="2"><a class='fancybox fancybox.iframe button2' href='admin_orderitemadd.jsp'>A�adir Producto</a></td><td></td><td></td><td></td><td></td></tr>
            </table>
        </div>       
    </div>
</section>

<script>
    $().ready(function () {
        $('#username').change(function () {
            sethref();
        });
        $('#address').change(function () {
            sethref();
        });
        $('#creditcard').change(function () {
            sethref();
        });
        $(".fancybox").fancybox({
            fitToView: false,
            autoSize: false,
            autoDimensions: false,
            width: 370,
            height: 260,
            afterClose: function () {
                location.href = 'admin_orderadd.jsp' + '?' + Math.random();
            } //window.location.reload(); }
        });
        sethref();
        function sethref() {
            var username = $('#username').val();
            var address = $('#address').val();
            var creditcard = $('#creditcard').val();
            var url = 'admin_orderitemadd.jsp?username=' + username + '&address=' + address + '&creditcard=' + creditcard;
            $('.fancybox').attr('href', url);
        }
    });
</script>
<jsp:include page="layout_sidebar.jsp" />
<jsp:include page="layout_footer.jsp" />