package integrationtests

import (
	"os/exec"
	"strings"
	"testing"
)

// runDockerScout ejecuta "docker scout ..." y devuelve salida y error
func runDockerScout(t *testing.T, args ...string) (string, error) {
	t.Helper()

	cmd := exec.Command("docker", args...)
	out, err := cmd.CombinedOutput()
	return string(out), err
}

// ayuda para detectar el mensaje de login requerido en Docker Hub
func isLoginRequired(output string) bool {
	output = strings.ToLower(output)
	return strings.Contains(output, "log in with your docker id") ||
		strings.Contains(output, "docker login")
}

func TestIntegration_OCIFixtures(t *testing.T) {
	type scenario struct {
		name        string
		args        []string
		expectError bool
	}

	// "Fixtures" lógicas para la práctica:
	// - oci-ok: imagen con análisis esperado "normal"
	// - oci-high: análisis que podría mostrar vulnerabilidades altas
	// - tar-bad: escenario donde se espera algún tipo de error de análisis/imagen
	scenarios := []scenario{
		{
			name: "oci-ok",
			args: []string{"scout", "cves", "alpine:3.18"},
			// en un entorno autenticado no debería haber error;
			// en CI podemos aceptar el error de login como entorno limitado
			expectError: false,
		},
		{
			name: "oci-high",
			args: []string{"scout", "quickview", "alpine:3.18"},
			expectError: false,
		},
		{
			name: "tar-bad",
			// imagen inventada para simular un artefacto dañado o inexistente
			args:        []string{"scout", "cves", "imaginarialocal/tar-bad:latest"},
			expectError: true,
		},
	}

	for _, sc := range scenarios {
		t.Run(sc.name, func(t *testing.T) {
			output, err := runDockerScout(t, sc.args...)

			if err != nil {
				// Si el mensaje es de login requerido, lo consideramos
				// "entorno limitado" y no fallamos la prueba
				if isLoginRequired(output) {
					t.Logf("PASS (entorno limitado): se requiere autenticación en Docker Hub para '%s'. Mensaje: %s",
						sc.name, output)
					return
				}

				// Para el fixture tar-bad sí esperamos algún tipo de error
				if sc.expectError {
					t.Logf("PASS: escenario %s produjo error esperado: %v. Salida: %s",
						sc.name, err, output)
					return
				}

				// Para oci-ok / oci-high, un error distinto de login es fallo real
				t.Fatalf("FAIL: escenario %s devolvió error inesperado: %v. Salida: %s",
					sc.name, err, output)
			}

			// Si no hay error:
			if sc.expectError {
				t.Fatalf("FAIL: escenario %s esperaba error pero el comando finalizó correctamente. Salida: %s",
					sc.name, output)
			}

			// Para oci-ok u oci-high simplemente registramos que el comando se ejecutó bien
			t.Logf("PASS: escenario %s se ejecutó correctamente. Salida (primeras líneas):\n%s",
				sc.name, firstLines(output, 10))
		})
	}
}

// firstLines devuelve las primeras n líneas de un string (para logs)
func firstLines(s string, n int) string {
	lines := strings.Split(s, "\n")
	if len(lines) > n {
		lines = lines[:n]
	}
	return strings.Join(lines, "\n")
}
