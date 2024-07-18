# Guía o *Step by Step* para configurar un *client* en keycloak

**En el panel de administración se accede a *Clients***

![Captura][i01]

**Se crea un *client***

![Captura][i02]

**Se especifica un clientID único**.

![Captura][i03]

**Se habilita el client authentication sólamente (en esta demo no se hará la *Authorization*).**

![Captura][i04]

**En el último paso es importante introducir la '*Valid redirect URI*'** (los otros campos son prescindibles). Aquí se configurarán la URLs válidas (o autorizadas dicho de otra forma), para que keycloak haga la petición con un token válido, una vez concluído satisfactoriamente el proceso de autenticación.

![Captura][i05]

<!-- Capturas -->
[i01]: ./img/captura01.png
[i02]: ./img/captura02.png
[i03]: ./img/captura03.png
[i04]: ./img/captura04.png
[i05]: ./img/captura05.png
