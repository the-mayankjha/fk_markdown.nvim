# LaTeX Math Equation Test Document

This document contains a wide variety of LaTeX math equations to test the rendering capabilities of the `fk_markdown.nvim` Neovim plugin. It covers inline math, display blocks, matrices, calculus, syntax arrays, and advanced formatting.

## 1. Inline and Block Math Basics
* **Inline Math:** The famous mass-energy equivalence is $E = mc^2$, formulated by Albert Einstein. Another basic relation is $a^2 + b^2 = c^2$.
* **Display Block Math:**
$$\gamma = \frac{1}{\sqrt{1 - v^2/c^2}}$$

## 2. Standard Algebraic Equations
The **Quadratic Formula** is used to find the roots of a quadratic equation:
$$x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$$

A system of linear equations using the standard `align*` or block formatting syntax:
$$
\begin{aligned}
3x + 2y - z &= 1 \\
2x - 2y + 4z &= -2 \\
-x + \frac{1}{2}y - z &= 0
\end{aligned}
$$

## 3. Calculus and Analysis
* **Limits:**
$$\lim_{x \to \infty} \left(1 + \frac{1}{x}\right)^x = e$$

* **Derivatives:**
$$\frac{d}{dx}\left(\ln|x|\right) = \frac{1}{x}$$

* **Partial Derivatives (Navier-Stokes element):**
$$\frac{\partial \rho}{\partial t} + \nabla \cdot (\rho \mathbf{u}) = 0$$

* **Integrals (Fundamental Theorem of Calculus):**
$$\int_{a}^{b} f'(x) \, dx = f(b) - f(a)$$

* **Improper Multi-Variable Integral:**
$$\int_{-\infty}^{\infty} e^{-x^2} \, dx = \sqrt{\pi}$$

## 4. Sequences, Series, and Summations
* **Infinite Series (Riemann Zeta Function):**
$$\zeta(s) = \sum_{n=1}^{\infty} \frac{1}{n^s}$$

* **Fourier Series expansion:**
$$f(x) = \frac{a_0}{2} + \sum_{n=1}^{\infty} \left( a_n \cos\left(\frac{n\pi x}{L}\right) + b_n \sin\left(\frac{n\pi x}{L}\right) \right)$$

* **Product Notation:**
$$\prod_{n=1}^{\infty} \left(1 - \frac{1}{4n^2}\right) = \frac{2}{\pi}$$

## 5. Linear Algebra and Matrices
* **Standard 3x3 Matrix ($A$):**
$$
A = \begin{pmatrix}
a_{11} & a_{12} & a_{13} \\
a_{21} & a_{22} & a_{23} \\
a_{31} & a_{32} & a_{33}
\end{pmatrix}
$$

* **Determinant with brackets:**
$$
|B| = \begin{vmatrix}
\lambda - a & b \\
c & \lambda - d
\end{vmatrix} = (\lambda - a)(\lambda - d) - bc
$$

* **Identity Matrix (with bracket options):**
$$
I_3 = \begin{bmatrix}
1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 & 1
\end{bmatrix}
$$

## 6. Advanced Physics and Statistics
* **Maxwell's Equations:**
$$
\begin{aligned}
\nabla \cdot \mathbf{E} &= \frac{\rho}{\varepsilon_0} \\
\nabla \cdot \mathbf{B} &= 0 \\
\nabla \times \mathbf{E} &= -\frac{\partial \mathbf{B}}{\partial t} \\
\nabla \times \mathbf{B} &= \mu_0\mathbf{J} + \mu_0\varepsilon_0\frac{\partial \mathbf{E}}{\partial t}
\end{aligned}
$$

* **Schrödinger Equation (Time-Dependent):**
$$i\hbar\frac{\partial}{\partial t}\Psi(\mathbf{r},t) = \hat{H}\Psi(\mathbf{r},t)$$

* **Gaussian Distribution (Probability Density Function):**
$$f(x \mid \mu, \sigma^2) = \frac{1}{\sqrt{2\pi\sigma^2}} \exp\left( -\frac{(x - \mu)^2}{2\sigma^2} \right)$$

## 7. Piecewise Functions and Cases
The absolute value function can be defined thoroughly using a `cases` environment block:
$$
|x| = \begin{cases}
x & \text{if } x \ge 0, \\
-x & \text{if } x < 0.
\end{cases}
$$

## 8. Miscellaneous Complex Layouts & Brackets
* **Nested fractions and large brackets:**
$$
K_n = 1 + \cfrac{1}{1 + \cfrac{1}{1 + \cfrac{1}{1 + \ddots}}}
$$

* **Binomial Coefficient:**
$$\binom{n}{k} = \frac{n!}{k!(n-k)!}$$

* **Set Notation:**
$$\forall x \in \mathbb{R}, \exists y \in \mathbb{R} \text{ such that } y > x^3$$
