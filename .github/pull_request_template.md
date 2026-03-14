# `Título Resumido da Mudança`

## Descrição do PR
> *Use este espaço para explicar **o que** foi feito e **por que** foi feito. Ajude o revisor a entender o contexto e o objetivo.*

| Item | Descrição |
| :--- | :--- |
| **US`xxx`- TK`xxx`** | `Nome da Issue/Tarefa` |
| **US`xxx`- TK`xxx`** | `Nome da Issue/Tarefa` |
| **US`xxx`- TK`xxx`** | `Nome da Issue/Tarefa` |

## Prova de Funcionamento
> *Inclua capturas de tela, GIFs ou links para vídeos que demonstrem a funcionalidade implementada.*

## Instruções para Testes
> *Instruções claras para o revisor testar as mudanças localmente.*

---

## Definition of Done (DoD)
> *O autor do PR deve verificar **todos** os itens antes de solicitar a revisão.* Remova os itens que não se aplicam ao seu PR.

### 1. Qualidade e Arquitetura do Código
- [ ] O código segue os padrões de formatação e linting do projeto (sem *warnings* ou *errors*).
- [ ] O código é limpo, legível e possui a complexidade mínima necessária.
- [ ] Não há código comentado ou logs de `print()`/`console.log()` desnecessários.

### 2.  Cobertura de Testes
- [ ] Todos os testes existentes passaram (CI/Local).
- [ ] **Se incluir ViewModel:** A ViewModel está testada ao máximo possível.
- [ ] **Se incluir Serviço:** Foi criado/atualizado um **Protocolo** e um **Mock** correspondente para o serviço.
- [ ] Foram adicionados novos testes de unidade (ou integrados, se aplicável) para cobrir a nova funcionalidade/correção.

### 3. User Interface (UI)
- [ ] As Views implementadas estão fiéis ao design do Figma/Sketch.
- [ ] Foi verificado o comportamento em diferentes tamanhos de tela (responsividade).
- [ ] Foi verificado o comportamento para diferentes estados (e.g., loading, vazio, erro).

### 4. Revisão e Documentação
- [ ] O título e a descrição do PR são claros e suficientes para o revisor.
- [ ] O mentor foi marcado para revisão.
- [ ] Foram atualizados os documentos relacionados (e.g., README, documentação de API).
- [ ] **Se for uma *breaking change*:** O impacto e o plano de migração foram descritos claramente.
