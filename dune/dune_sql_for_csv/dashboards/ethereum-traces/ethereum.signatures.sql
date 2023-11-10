select
    *
from
    ethereum.signatures
where
    name in (
        'CompFarmingContract',
        'CErc20Delegator',
        'cErc20',
        'UsdcPriceOracle',
        'FiatTokenV2_1',
        'USDC',
        'FiatTokenV2_1',
        'Unitroller',
        'SoloMargin',
        'OperationImpl'
    )
    and namespace in (
        'compfarmingcontract',
        'compound_v2',
        'dydx',
        'usdc_mk_v1',
        'circle',
        'cadc'
    )