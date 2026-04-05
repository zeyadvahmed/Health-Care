// ============================================================
// custom_textfield.dart
// Reusable styled TextFormField used in all forms across the app.
//
// Usage:
//   CustomTextField(
//     label: 'Email',
//     hint: 'Enter your email',
//     controller: _emailController,
//     validator: Validators.validateEmail,
//     keyboardType: TextInputType.emailAddress,
//   )
//   CustomTextField(
//     label: 'Password',
//     hint: 'Enter your password',
//     controller: _passwordController,
//     validator: Validators.validatePassword,
//     isPassword: true,
//   )
//
// Parameters:
//   label        — label text shown above the field (required)
//   hint         — placeholder text inside the field (required)
//   controller   — TextEditingController linked to this field (required)
//   validator    — validation function from Validators class (required)
//   isPassword   — enables password obscuring with eye icon toggle
//   icon         — optional leading icon inside the field
//   keyboardType — keyboard type, defaults to TextInputType.text
//   onChanged    — optional callback fired on every keystroke
//
// Rules:
//   - StatefulWidget — needed for the password visibility toggle state
//   - Use AppColors for all colors
//   - Use AppTheme inputDecorationTheme as base style
//   - Eye icon toggles _isObscured bool in state
// ============================================================