/// Como a conta logada entra no app; decide como reautenticar antes de excluir.
enum AccountProvider { password, google, apple, unknown }

/// Código da falha quando o usuário fecha a folha do Google/Apple na
/// confirmação da exclusão da conta (a tela só volta, sem erro).
const String deleteAccountCanceledCode = 'delete-canceled';
