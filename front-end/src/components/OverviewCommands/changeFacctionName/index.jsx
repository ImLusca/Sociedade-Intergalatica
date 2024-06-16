import React ,{useState} from 'react';
import Styles from "./changeFacction.module.css"

const ChangeNameFacction = ({ nome, acao }) => {
    
    const [isChanging, setIsChanging] = useState(false);
    const [changeVal, setChangeVal] = useState(nome);

    const handleChangeName = ()=>{
        setIsChanging(!isChanging);
    }
    
    const handleCancel = ()=>{
        setIsChanging(false);
        setChangeVal(nome);
    }

    return (
        <>
            <h3>Nome da facção</h3>
            <div className={Styles.container}>

                {
                    isChanging ?
                        <input type="text" value={changeVal} onChange={(e)=>setChangeVal(e.target.value)}/>
                        : <h1>{changeVal}</h1>
                }
                <div className={Styles.buttons}>
                    {isChanging && <button onClick={handleCancel}>Cancelar</button>}                
                    <button onClick={handleChangeName}>Alterar nome</button>
                </div>
            </div>


        </>
    );
};

export default ChangeNameFacction;
